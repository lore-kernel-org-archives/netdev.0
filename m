From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] net/tulip: LAN driver for ULI M5261/M5263
Date: Fri, 29 Jul 2005 15:37:31 -0400
Message-ID: <42EA857B.5080608@pobox.com>
References: <OF9922119A.7A6623CD-ON4825704D.0040B00E@uli.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@redhat.com, Clear.Zhang@uli.com.tw,
	linux-kernel@vger.kernel.org, Emily.Jiang@uli.com.tw,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262778AbVG2Tlh@vger.kernel.org>
To: Peer.Chen@uli.com.tw
In-Reply-To: <OF9922119A.7A6623CD-ON4825704D.0040B00E@uli.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peer.Chen@uli.com.tw wrote:
> We want to extract our LAN card driver from tulip core driver and make a
> new file uli526x.c at tulip folder,
> because we have added some ethtool interface support and non-eprom support
> in our driver and may be other change
> in the futher. If our controllers support are still contained in the tulip
> core driver, I think it'll increase the
> complexity of maintenance,


After some thought, I agree with this assessment.

It has been my goal for a long time to separate out the various chips 
from the tulip driver, for easier maintenance.  One of the reasons I 
have not applied a "fix tulip for ULi" patch is that it changes PHY 
details that I am not sure are OK for the myriad tulip clones.  A 
separate driver eliminates this objection.

I have applied your patch to the new 'uli-tulip' branch of git 
repository 
rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

Please now do the following tasks:

1) Submit an incremental patch addressing Alexey Dobriyan's minor complaints

2) Submit a patch removing all ULi support from the 'tulip' driver


I will then conduct a final review, and probably request another patch, 
with more updates.

After that, your driver will be sent upstream, to be included in the 
official 2.6.x kernel.

Thanks and regards,

	Jeff
