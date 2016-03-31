From: Eliad Peller <eliad@wizery.com>
Subject: Re: [PATCH 0/5] wireless: ti: Convert specialized logging macros to
 kernel style
Date: Thu, 31 Mar 2016 11:59:39 +0300
Message-ID: <CAB3XZEfePJG7t6+TGYer_pcdqqaTfYugK0cARwhgLm9KRG1fmg@mail.gmail.com>
References: <cover.1457395071.git.joe@perches.com>
	<87shz85gkq.fsf@purkki.adurom.net>
	<1459373791.25110.132.camel@perches.com>
	<87y48z3xkz.fsf@purkki.adurom.net>
	<1459411668.1744.6.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	Guy Mishol <guym@ti.com>,
	Uri Mashiach <uri.mashiach@compulab.co.il>,
	Johannes Berg <johannes.berg@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459411668.1744.6.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2016 at 11:07 AM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2016-03-31 at 10:39 +0300, Kalle Valo wrote:
>> Joe Perches <joe@perches.com> writes:
>> > On Wed, 2016-03-30 at 14:51 +0300, Kalle Valo wrote:
>> > > Joe Perches <joe@perches.com> writes:
>> > > >
>> > > > Using the normal kernel logging mechanisms makes this code
>> > > > a bit more like other wireless drivers.
>> > > Personally I don't see the point but I don't have any strong opinions. A
>> > > bigger problem is that TI drivers are not really in active development
>> > > and that's I'm not thrilled to take big patches like this for dormant
>> > > drivers.
>> > Not very dormant.
>> >
>> > 35 patches in the last year, most of them adding functionality.
>> Oh, I didn't realise it had that many patches. But the driver is
>> orphaned and doesn't have a maintainer so could I then have an ack from
>> one of the active contributors that this ok?
>
> Fine by me.
>
> $ ./scripts/get_maintainer.pl -f --git drivers/net/wireless/ti/
>
> Kalle Valo <kvalo@codeaurora.org> (maintainer:NETWORKING DRIVERS (WIRELESS),commit_signer:27/35=77%)
> Eliad Peller <eliad@wizery.com> (commit_signer:9/35=26%,authored:7/35=20%)
> Guy Mishol <guym@ti.com> (commit_signer:6/35=17%,authored:5/35=14%)
> Johannes Berg <johannes.berg@intel.com> (commit_signer:6/35=17%,authored:3/35=9%)
> Uri Mashiach <uri.mashiach@compulab.co.il> (commit_signer:4/35=11%,authored:4/35=11%)
>
> For those people now added to the cc list,
> here's the original patch thread:
>
> https://lkml.org/lkml/2016/3/7/1099

I don't have a strong opinion here either.
(I do like the trailing newline being added automatically, but that's
hardly an issue...)

Eliad.
