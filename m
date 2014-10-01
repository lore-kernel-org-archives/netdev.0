From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a
 refcnt on port.
Date: Wed, 1 Oct 2014 15:23:25 -0400
Message-ID: <20141001192325.GK17706@oracle.com>
References: <20141001185622.GI17706@oracle.com>
 <542C50A4.30304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38919 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaJATXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:23:30 -0400
Content-Disposition: inline
In-Reply-To: <542C50A4.30304@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/01/14 15:06), David L Stevens wrote:
> 
> This "vp->switch_port" addition doesn't appear to be related to the port refcnt
> change, and doesn't allow for multiple switch ports.

The switch_port is the connection to Dom0. Do you envision us having more than
one switch_port? How?

--Sowmini
