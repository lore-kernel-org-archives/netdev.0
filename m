From: "tgraf@suug.ch" <tgraf@suug.ch>
Subject: Re: [patch net-next v3 07/17] rocker: introduce rocker switch driver
Date: Tue, 25 Nov 2014 21:57:54 +0000
Message-ID: <20141125215754.GC3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-8-git-send-email-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6D1C9FB50A@AcuExch.aculab.com>
 <CAE4R7bC=jnq=OX2BNa9hpzbx8fpxHF+zGf1cV1ahP31htpE7kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.co
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56601 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbaKYV54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 16:57:56 -0500
Content-Disposition: inline
In-Reply-To: <CAE4R7bC=jnq=OX2BNa9hpzbx8fpxHF+zGf1cV1ahP31htpE7kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 09:19am, Scott Feldman wrote:
> On Tue, Nov 25, 2014 at 6:13 AM, David Laight <David.Laight@aculab.com> wrote:
> > From: Jiri Pirko
> >>
> >> This patch introduces the first driver to benefit from the switchdev
> >> infrastructure and to implement newly introduced switch ndos. This is a
> >> driver for emulated switch chip implemented in qemu:
> >> https://github.com/sfeldma/qemu-rocker/
> >
> > If this driver caller 'rocker' just to get the (bad) pun 'rocker switch'?
> > IMHO A more descriptive name would be a lot better.
> 
> Sorry, it's the best we could do since qla3xxx and mlx4 and fm10k were
> already taken.

Given the amount of momentum rocker has created in the cause of
driving this API forward, I find the name quite appropriate.
