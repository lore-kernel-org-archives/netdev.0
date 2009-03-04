From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Tue, 03 Mar 2009 23:43:27 -0800 (PST)
Message-ID: <20090303.234327.81716668.davem@davemloft.net>
References: <20090228180541.GA729@jukie.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bart@jukie.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751960AbZCDHnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 02:43:42 -0500
In-Reply-To: <20090228180541.GA729@jukie.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart Trojanowski <bart@jukie.net>
Date: Sat, 28 Feb 2009 13:05:41 -0500

> 2.6.29-rc* introduces a bug that causes a crash when a vlan is put into
> another vlan, so called vlan trunking or QinQ.
> 
> I can reproduce it reliably with:
> 
>   $ modprobe 8021q
>   $ vconfig add eth1 5
>   $ ifconfig eth1.5 up
>   $ vconfig add eth1.5 4

Stephen please fix this.
