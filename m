From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] bonding: reduce noise during init
Date: Tue, 26 Jul 2011 18:08:22 -0700
Message-ID: <1311728902.15386.47.camel@Joe-Laptop>
References: <1311716107-12328-1-git-send-email-andy@greyhouse.net>
	 <1311717286.15386.34.camel@Joe-Laptop> <11239.1311727039@death>
	 <1311727227.15386.40.camel@Joe-Laptop>
	 <CAHashqDd8iFou7MsdCU2=2mEyaSo5RvsJoqd47jZTCwwdU81eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4326 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824Ab1G0BIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 21:08:23 -0400
In-Reply-To: <CAHashqDd8iFou7MsdCU2=2mEyaSo5RvsJoqd47jZTCwwdU81eA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-26 at 20:56 -0400, Andy Gospodarek wrote:
> On Jul 26, 2011 8:40 PM, "Joe Perches" <joe@perches.com> wrote:
> > On Tue, 2011-07-26 at 17:37 -0700, Jay Vosburgh wrote:
> > > Joe Perches <joe@perches.com> wrote:
> > > >I'd prefer you don't separate the format string
> > > >into multiple pieces.
> > > Why not?  To me, it looks easier to read split into sections
> > > that don't wrap lines.
> > Harder to grep for a dmesg and the
> > defect rate of these split formats is
> > typically higher than single strings
> > because of bad spacing between string
> > segments.
> I'll agree that grepping based on dmesg/log output can be more
> difficult, but incorrect spacing should simply be fixed rather than a
> wholesale ban.

I didn't know I can ban things.
Cool.  Do I get a sceptre too?

> The visual benefit when looking at the code makes this really nice, so
> I would prefer to breakup long strings when changing nearby code. 

Up to you.

One other possible benefit of keeping formats
together is that if the message is overly long,
(ideally dmesg should have messages < 80 chars)
then it's more obvious that it should be somehow
shortened.

cheers, Joe

