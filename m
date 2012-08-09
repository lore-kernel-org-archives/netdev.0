From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] net: add new QCA alx ethernet driver
Date: Thu, 9 Aug 2012 12:13:38 -0700
Message-ID: <CAB=NE6X4JQmQgtgcy9is0hn0nNypTKJN-d2RHFR7vvg=vO_eHQ@mail.gmail.com>
References: <6349D7A510622448B1BA0967850A8438013692CA@NASANEXD02D.na.qualcomm.com>
 <1344485382.2024.9.camel@joe2Laptop> <6349D7A510622448B1BA0967850A843801369364@NASANEXD02D.na.qualcomm.com>
 <20120808.231804.12694947300243733.davem@davemloft.net> <6349D7A510622448B1BA0967850A8438013693DD@NASANEXD02D.na.qualcomm.com>
 <20120809145454.GA21195@home.goodmis.org> <1344525758.3165.8.camel@joe2Laptop>
 <1344526098.6935.44.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	"hao-ran.liu@canonical.com" <hao-ran.liu@canonical.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344526098.6935.44.camel@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 9, 2012 at 8:28 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Thu, 2012-08-09 at 08:22 -0700, Joe Perches wrote:
>
>> Yes, I sent signed-off patches to their original RFC submission
>> (back last year?).

And that is why your SOB was kept.

>> To me, this single large patch is like a
>> snapshot of a git tree and not all contributors to that git
>> tree should be noted as signers of the entire thing.

I am not sure we really ever addressed this technical difference and
from what I have seen we always run into this question on new driver
submissions.

Entity x goes on and posts driver joojoo-1, and we some folks in the
community may merge such patch onto their tree and edit the driver and
send some of their own changes and improvements to the developers /
mailing list. Typically if the patches sent had a SOB tag the right
thing to due given the legal implications of the Developer's
Certificate of Origin is to add those SOBs to the new driver
submission if company x goes on and posts joojoo-2.. but...

> Ouch, that looks like we are losing all history.

Agreed! It'd be best instead to have such changes as part of a linear
history somewhere so maybe what would be right prior to inclusion
upstream is for such patches to be merged on an external github tree
or wherever to be able to keep record of the submissions done during
development. Then upon submission to the Linux kernel again as
joojoo-2 instead of joojoo-1 company x would simply provide their own
SOB, and the record of the previous SOBs would be kept on the forked
git tree.

Whether or not it is required to have the SOB tog of previous patch
submitters is not clear but to me its not necessary if you have a
record somewhere that they were submitted and merged in some other
tree. The mailing list alone may serve as a good place holder for this
information as well so a separate tree may not be required.

So -- are we OK to *not* include SOBs of evolutions sent to developers
of joojoo-1 when company x submits joojoo-2 so long as those patches
were sent publicly or a record is kept somewhere ?

> One large patch should not be submitted. If it was developed in steps,
> then it is best to show those steps when they are incorporated into the
> Linux repository.

Sure, but at times some changes are asked after a submission of
joojoo-1, and at times this may be ongoing until maybe even joojoo-10,
before we are happy to merge it upstream.

  Luis
