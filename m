From: Joe Perches <joe@perches.com>
Subject: Re: Kill I4L? (was: [PATCH 2/6] drivers: isdn: act2000: capi.c: fix
 checkpatch errors)
Date: Sun, 08 Feb 2015 12:04:06 -0800
Message-ID: <1423425846.2933.15.camel@perches.com>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
	 <1423328797-17865-3-git-send-email-baspeters93@gmail.com>
	 <54D650BF.5000400@cogentembedded.com> <1423336761.2933.7.camel@perches.com>
	 <1423341800.2246.68.camel@x220> <54D7BD4A.4090101@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de,
	julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D7BD4A.4090101@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-02-08 at 20:47 +0100, Tilman Schmidt wrote:
> Am 07.02.2015 um 21:43 schrieb Paul Bolle:
> > On Sat, 2015-02-07 at 11:19 -0800, Joe Perches wrote:
> >> Does anyone still use these cards?
> > 0) Good question.
> I very much doubt it. It was an ISA card, not even PnP. I'd imagine
> any systems of that kind would be retired by now.
[]
> I guess
> somebody could just submit a patch series starting with:
> +++ b/drivers/isdn/Kconfig
> @@ -20,25 +20,6 @@ menuconfig ISDN
> 
>  if ISDN
> 
> -menuconfig ISDN_I4L
> -       tristate "Old ISDN4Linux (deprecated)"
> -       depends on TTY
[]
> Shall I?

I think removing code for completely unused,
no longer sold or supported devices could be
a good thing.

If someone pipes up saying "I use that" within
some shortish time-frame, it's easy to undo.
