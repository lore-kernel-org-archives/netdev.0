From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 V5 PATCH 2/3] Add ndo_{set|get}_vf_port_profile op support for enic dynamic vnics
Date: Thu, 6 May 2010 18:45:16 +0200
Message-ID: <201005061845.16751.arnd@arndb.de>
References: <C8083B9D.2EC18%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:52589 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569Ab0EFQpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 12:45:18 -0400
In-Reply-To: <C8083B9D.2EC18%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 May 2010, Scott Feldman wrote:
> Dynamic enics have all-zero mac address on init, so we assign a random mac
> addr to the interface.  This would seem less funny:
> 
>     if (enic_is_dynamic(enic) && is_zero_ether_addr(addr))
>         random_ether_addr(netdev->dev_addr);
>     else
>         ...
> 
> I'll make that change and resubmit with your VDP additions if you like.

The change is ok, but what I think would be more helpful is a code comment
with your above sentence.

	Arnd
