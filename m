From: Mike Isely <isely@isely.net>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Tue, 13 Feb 2007 17:32:44 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0702131730570.14346@cnc.isely.net>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com>
 <20061204000327.GE3625@electric-eye.fr.zoreil.com> <45D13578.8040405@snapgear.com>
 <20070213081439.GA21261@electric-eye.fr.zoreil.com>
Reply-To: Mike Isely <isely@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Philip Craig <philipc@snapgear.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, Mike Isely at pobox <isely@pobox.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnc.isely.net ([64.81.146.143]:59025 "EHLO cnc.isely.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbXBMXhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 18:37:53 -0500
In-Reply-To: <20070213081439.GA21261@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Feb 2007, Francois Romieu wrote:

> Philip Craig <philipc@snapgear.com> :
> [...]
> > This patch caused a drop in throughput from 178 Mbits/sec to 135 Mbits/sec
> > on an Intel XScale IXP465.
> 
> Which distribution of packet sizes ?
> 
> > It seems like there is some confusion about what the align parameter
> > here means. It was originally an offset from an aligned address so that
> > the IP header aligned, and this patch changes it to the alignment of the
> > ethernet header. But align is still set to NET_IP_ALIGN for some chips.
> 
> Yes, I should have distinguished both in the first place.
> 
> Can you describe which chipset from realtek the board is using (lspci -vxx) ?
> 

Francois:

Obviously I have an interest in any change here not breaking the NIC on 
my system.  So please let me know if/when you'd like me to test drive a 
candidate fix that keeps everyone happy...

  -Mike


-- 
                        |         Mike Isely          |     PGP fingerprint
     Spammers Die!!     |                             | 03 54 43 4D 75 E5 CC 92
                        |   isely @ pobox (dot) com   | 71 16 01 E2 B5 F5 C1 E8
                        |                             |
