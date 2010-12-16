From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC][PATCH] Export DNSSL RA option to userspace
Date: Wed, 15 Dec 2010 19:18:24 -0600
Message-ID: <1292462307.31873.30.camel@dcbw.foobar.com>
References: <20101212144300.68e0fb16@mjolnir.ossman.eu>
	 <1292332218.15586.49.camel@i7.infradead.org>
	 <20101214144319.02eced29@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Pierre Ossman <pierre-list@ossman.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365Ab0LPBTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 20:19:55 -0500
In-Reply-To: <20101214144319.02eced29@mjolnir.ossman.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-14 at 14:43 +0100, Pierre Ossman wrote:
> On Tue, 14 Dec 2010 13:10:15 +0000
> David Woodhouse <dwmw2@infradead.org> wrote:
> 
> > On Sun, 2010-12-12 at 14:43 +0100, Pierre Ossman wrote:
> > > RFC 6106 specifies a new RA option for DNS resolver configuration that
> > > therefore needs to end up in userspace.
> > > 
> > > This first patch just exports the new option, but I started thinking
> > > that this seems overly complex that the kernel needs to be updated
> > > every time there is something new of interest to userspace in the RA.
> > > So I also have a second patch that exports everything that the kernel
> > > doesn't want.
> > > 
> > > Patches only compile tested so far as I'm still hacking away at
> > > userspace. Comments very much welcome though.
> > 
> > Totally untested userspace support:
> > http://git.infradead.org/users/dwmw2/connman.git
> > 
> 
> Tested userspace support in the form of NetworkManager: ;)
> 
> https://bugzilla.gnome.org/show_bug.cgi?id=637077

And pushed to master and stable branches too.  Thanks for the work on
this!

Dan


> And a radvd to send things out:
> 
> http://lists.litech.org/pipermail/radvd-devel-l/2010-December/000507.html
> 
> Rgds


