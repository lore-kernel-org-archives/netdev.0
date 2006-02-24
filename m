From: Wolfgang Hoffmann <woho@woho.de>
Subject: Re: [git patches] net driver fixes
Date: Fri, 24 Feb 2006 08:59:22 +0100
Message-ID: <200602240859.23062.woho@woho.de>
References: <20060224052214.GA14586@havoc.gtf.org>
Reply-To: woho@woho.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750916AbWBXH56@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060224052214.GA14586@havoc.gtf.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 24 February 2006 06:22, Jeff Garzik wrote:
> Please pull from 'upstream-fixes' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>
> [...]
> Stephen Hemminger:
>       sky2: yukon-ec-u chipset initialization
>       sky2: limit coalescing values to ring size
>       sky2: poke coalescing timer to fix hang
>       sky2: force early transmit status
>       sky2: use device iomem to access PCI config
>       sky2: close race on IRQ mask update.
>[...]

Thanks for the update.

Still I'm seeing reproducable hangs with this version of sky2 (as reported in 
bugzilla 6084 and discussed on netdev).

Stephen, if there is anything I can do to narrow down my hangs a bit more 
systematically, please let me know, I'd be happy to help.

Wolfgang
