From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a
 refcnt on port.
Date: Wed, 1 Oct 2014 15:44:03 -0400
Message-ID: <20141001194403.GM17706@oracle.com>
References: <20141001185622.GI17706@oracle.com>
 <1412190324.16704.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36955 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaJAToL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:44:11 -0400
Content-Disposition: inline
In-Reply-To: <1412190324.16704.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/01/14 12:05), Eric Dumazet wrote:
> 
> Hmpff... This calls for rcu protection here !
> 

I did consider that, but given that the lists containing the ports are
accessed in multiple contexts, some of which can sleep, and given that
the vnet port is similar in spirit to the net_device, I followed the
net_device model of dev_put etc.

--Sowmini
