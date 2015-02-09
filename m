From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: Kill I4L?
Date: Mon, 09 Feb 2015 13:12:02 +0100
Message-ID: <1423483922.2246.112.camel@x220>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
		 <1423328797-17865-3-git-send-email-baspeters93@gmail.com>
		 <54D650BF.5000400@cogentembedded.com>
	 <1423336761.2933.7.camel@perches.com> <1423341800.2246.68.camel@x220>
	 <54D7BD4A.4090101@imap.cc> <54D7F87E.4050506@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>, Joe Perches <joe@perches.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de,
	julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <kkeil@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D7F87E.4050506@linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-02-09 at 00:59 +0100, Karsten Keil wrote:
> Am 08.02.2015 um 20:47 schrieb Tilman Schmidt:
> > Am 07.02.2015 um 21:43 schrieb Paul Bolle:
> >> 2) Broader picture: if I remember correctly there are now four
> >> different flavors of ISDN in the kernel: - really old: pre-i4l
> > 
> > I don't think any traces of that are still present in current kernel
> > releases. It should all have been left behind on the switch to 2.6. 
> 
> Yes.

I just refreshed my memory: drivers/isdn/hysdn predates I4L. It was
added in v2.3.45, while I4L was mainlined in v2.6.4. But, on the other
hand, one can optionally use HYSDN via "just old" CAPI.

(HYSDN looks a bit odd. By default "they register as ethernet card". I
guess this will only work if both ends of the ISDN connection have a
setup like that. But, who knows, maybe someone is still using HYSDN in
that way. www.hypercope.de serves "Sponsored Listings", by the way.)

> >> - very old: i4l - just old: CAPI - not so old: mISDN
> > 
> > Those are the in-tree ones. To make matters worse, the Asterisk people
> > invented three more (Zaptel, DAHDI and vISDN) which are maintained
> > out-of-tree. Apparently they weren't satisfied with any the in-tree
> > ones and didn't feel like helping to improve one of them to match
> > their needs.
> > 
> >> [snip] So the current ISDN situation is a bit messy.
> > 
> > That's putting it mildly.
> > 
> >> Tilman might be able to provide a clearer, and maybe less grumpy, 
> >> summary of the current situation.
> > 
> > Don't know about either. ;-)


Paul Bolle
