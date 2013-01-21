From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Mon, 21 Jan 2013 11:05:37 -0500 (EST)
Message-ID: <954103681.96056.1358784337915.JavaMail.root@elliptictech.com>
References: <50FD637F.2080604@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	David Dillow <dave@thedillows.org>,
	Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50FD637F.2080604@genband.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Chris Friesen" <chris.friesen@genband.com>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "Steven Rostedt" <rostedt@goodmis.org>, "David Dillow" <dave@thedillows.org>, "Borislav Petkov" <bp@alien8.de>,
> linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Sent: Monday, 21 January, 2013 10:49:19 AM
> Subject: Re: IPsec AH use of ahash
> 
> On 01/21/2013 09:31 AM, Tom St Denis wrote:
> > ----- Original Message -----
> >> From: "Steven Rostedt"<rostedt@goodmis.org> To: "Tom St
> >> Denis"<tstdenis@elliptictech.com> Cc: "David
> >> Dillow"<dave@thedillows.org>, "Borislav Petkov"<bp@alien8.de>,
> >> linux-kernel@vger.kernel.org, netdev@vger.kernel.org Sent: Monday,
> >> 21 January, 2013 10:28:33 AM Subject: Re: IPsec AH use of ahash
> >>
> >> When I send a patch to another maintainer, and they tell me to fix
> >> the way I did the comments, I don't complain. I fix the comments
> >> and resend.
> >
> > Which is less of a problem when there is a timeliness factor.  In
> > the
> > business world people move on and don't work at that pace.
> 
> There can be an impedance mismatch between the "get it done to hit a
> deadline" business world and the "get it right no matter how long it
> takes" world of some open-source projects.

I think part of it is the nature of the job.  Here working with the kernel is a by-product of the atmosphere we're in (embedded hardware).  We're not per se a "Linux Shop" ...

So for our case when CMAC code was working and the patch fired off we were "done."  Granted now that bugs were found in the testmgr code spending time to fix it up was prudent.

The timeliness I was speaking of was to make sure that business windows are hit as well.  Had I had a rejection sooner when the project was still fresh and current it would have been no issue to re-spin the patches.
 
> However, many businesses have recognized that they get far more
> benefit
> from dealing with open-source than it costs them in designer time.
> 
>  From the point of view of my employer (I work in telecom) the
>  choices
> are either:
> 
> a) work with the kernel to get the code submitted into mainline
> b) keep the changes private and port them every time we upgrade
> 
> Over a decade or more my management has come to realize that option
> "a"
> is generally better in the long term, even if it's a bit more effort
> in
> the short term.
> 
> There are exceptions of course, and sometimes we just need to do a
> quick-and-dirty solution to get something out the door.

Yup agreed.  We don't plan to mainline our hardware drivers any time soon mostly because they're in flux too much and they're really only useful for businesses who order mostly custom designs (end home users wouldn't typically write drivers for them).

But at the same time we hit upon things in the kernel that prevent our private tree drivers from working (lacking CMAC for instance, or not being able to run AH-GMAC).  I'd like to see the CMAC issue move forward and then maybe contribute to the AH-AEAD front.

Tom
