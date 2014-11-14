From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1 net-next] net: dsa: replace count*size kmalloc by
 kmalloc_array
Date: Fri, 14 Nov 2014 11:42:11 -0800
Message-ID: <1415994131.5912.25.camel@perches.com>
References: <1415990202-28673-1-git-send-email-fabf@skynet.be>
	 <1415990835.5912.20.camel@perches.com>
	 <2104595537.56209.1415991758726.open-xchange@webmail.nmp.skynet.be>
	 <1415992486.5912.23.camel@perches.com>
	 <47990659.56515.1415993549555.open-xchange@webmail.nmp.skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <47990659.56515.1415993549555.open-xchange@webmail.nmp.skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-11-14 at 20:32 +0100, Fabian Frederick wrote:
> On 14 November 2014 at 20:14 Joe Perches <joe@perches.com> wrote:
> > On Fri, 2014-11-14 at 20:02 +0100, Fabian Frederick wrote:
> > > On 14 November 2014 at 19:47 Joe Perches <joe@perches.com> wrote:
> > > > On Fri, 2014-11-14 at 19:36 +0100, Fabian Frederick wrote:
> > > > > kmalloc_array manages count*sizeof overflow.
> > > >
> > > > Fundamentally correct, but is this necessary or useful?
> > > > sizeof(s8) isn't often going to be anything other than 1.
> > > Absolutely, I thought it was a struct :)
> > >
> > > There must be a reason for so many cases though ...
> >
> > Some might be style symmetry for other sizeof(othertype)
> > uses in the same paths, but most of them are just overkill
> > or maybe lack of understanding.
> 95% comes from drivers tree. I guess one patch to Greg would be enough.

I think it'd be better to send patches through the
appropriate various maintainers

Likely just using the 2nd level directory would be
good enough

$ git grep -E --name-only "\*\s*sizeof\s*\(\s*[us]8\s*\)" | \
  cut -f1-2 -d"/" | uniq
arch/arm
drivers/acpi
drivers/char
drivers/gpu
drivers/iio
drivers/infiniband
drivers/input
drivers/md
drivers/media
drivers/mtd
drivers/net
drivers/power
drivers/rtc
drivers/thermal
fs/compat_ioctl.c
net/dsa

> Are you interested in those patches or can I do them with some "Suggested-by" ?

Not really and no need.

cheers, Joe
