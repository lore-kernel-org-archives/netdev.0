From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: Broadcom 43xx first results
Date: Wed, 7 Dec 2005 19:00:27 -0500
Message-ID: <200512071900.27669.flamingice@sourmilk.net>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205191008.GA28433@infradead.org> <20051205203121.48241a08@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Christoph Hellwig <hch@infradead.org>,
	Joseph Jezak <josejx@gentoo.org>, mbuesch@freenet.de,
	linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965048AbVLHAAd@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <20051205203121.48241a08@griffin.suse.cz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 December 2005 14:31, Jiri Benc wrote:
> > And Joseph &
> > friends are writing a module to support softmac cards in that framework,
> > which is one of the most urgently needed things right now, because all
> > the existing softmac frameworks don't work with that code.
>
> And authors of rtl8180 did it too. And authors of adm8211 too.
>
The softmac code that is still in adm8211 is actually based on an early 
version of the softmac code that Jouni made for Devicescape. The Devicescape 
code does much more useful stuff than the code currently in the kernel. Sure, 
I can and have been porting adm8211 to the new kernel stuff.. but it already 
works with a much more mature piece of softmac code. I see the use of Intel's 
802.11 code as a step backwards.

-Michael Wu
