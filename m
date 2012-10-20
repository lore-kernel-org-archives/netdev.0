From: Borislav Petkov <bp@alien8.de>
Subject: Re: Re: A reliable kernel panic (3.6.2) and system crash when
 visiting a particular website
Date: Sun, 21 Oct 2012 00:58:49 +0200
Message-ID: <20121020225849.GA8976@liondog.tnic>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05>
 <20121020162759.GA12551@liondog.tnic>
 <966148591.30347.1350754909449.JavaMail.mail@webmail08>
 <20121020203227.GC555@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121020203227.GC555@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 20, 2012 at 10:32:28PM +0200, Pavel Machek wrote:
> On Sat 2012-10-20 17:41:49, Artem S. Tashkinov wrote:
> > On Oct 20, 2012, Borislav Petkov wrote: 
> > 
> > > Yeah, your kernel is tainted with a proprietary module (vbox*, etc). Can
> > > you reproduce your corruptions (this is what it looks like) without that
> > > module?
> > 
> > Yes, I can reproduce this panic with zero proprietary/non-free modules loaded.
> > 
> > The problem is the kernel doesn't even print a kernel panic - the
> > system just freezes completely - cursor in a text console stops
> > blinking.
> 
> bugtraq? :-).
> 
> If remote website can crash your Linux, that's quite significant news.
> 
> (Cc-ed netdev@ and security@ ... this may be important).

I don't think that's the problem - I rather suspect the fact that he's
using virtualbox which is causing random corruptions by writing to
arbitrary locations.

Artem,

please remove virtualbox completely from your system, rebuild the kernel
and make sure the virtualbox kernel modules don't get loaded - simply
delete them so that they are completely gone; *and* *then* retest again.

Thanks.

-- 
Regards/Gruss,
    Boris.
