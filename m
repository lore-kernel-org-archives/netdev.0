From: Sander <sander@humilis.net>
Subject: Re: e1000 -> 82540EM on linux 2.6.0-test[45] very slow in one direction
Date: Sat, 4 Oct 2003 08:49:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031004064952.GA27027@favonius>
References: <E3A930D59AFC3345AEBA35189102A8A6193289@orsmsx404.jf.intel.com>
Reply-To: sander@humilis.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ookhoi@humilis.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Leech, Christopher" <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <E3A930D59AFC3345AEBA35189102A8A6193289@orsmsx404.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leech, Christopher wrote (ao):
> > Btw, I had to compile the e1000 driver as a module. Compiled in it
> > doesn't work, as is stated on the intel support page:
> 
> > This is not clear from the kernel config help. A patch against
> > 2.6.0-test6 is attached (I don't know how to only give n/m as an
> > option).
> 
> This patch is not necessary or desired. The version of e1000 that ships
> with the kernel source should work fine statically linked, and the
> comment on the Intel support web page applies to the separate download
> of the e1000 source. If you download the driver source from Intel and
> do the work to add it into a kernel source tree yourself, Intel customer
> support may not help you when you have problems.
> 
> If you are having problems compiling in the version of e1000 that ships
> with the kernel, please report it on netdev and we'll try and help.

I'm sorry for the patch. The problem I had with e1000 compiled into the
kernel was that the interface resets every 60(?) seconds, and there was
no network connection. After a google search I came onto the intel
support page, saw the module-only text, tried e1000 as a module and it
worked. This all is with the e1000 driver which is in the 2.6.0-test6
kernel, which I thought was the intel provided driver.
The server is co-located now, so I'm sorry to say that I can't try
again to give more details.

> > Btw2, can somebody please explain what the option E1000_NAPI does?
> 
> NAPI is a network driver polling mode interface.  It enables a form of
> software managed interrupt moderation, and may result in better
> performance under some traffic patterns (specifically sustained high
> packet rate reception).

Aha, tnx. Can you please provide a patch to get this text in the 2.6
help?
