From: Reinoud Koornstra <reinoudkoornstra@gmail.com>
Subject: Re: [GIT] Networking
Date: Wed, 18 May 2016 06:51:55 -0600
Message-ID: <CAAA5faHtbt8oyKEQOJ+NMBKR24b7Nvm6uJ2qZid1sWY58e7f+A@mail.gmail.com>
References: <20160517.151113.367799295750703003.davem@davemloft.net>
	<CA+55aFw_JRGNo3HYP3c=3VoGw_uYBP_h2OmxOMcUGsU=L43btw@mail.gmail.com>
	<CANUX_P3n0ZkTw0fY8wD3biu2mLzrwyX7n=bo1otw9m0bpfS07Q@mail.gmail.com>
	<1463568714.13625.18.camel@intel.com>
	<CAAA5faF=SxqCt0yDTbPyUoc3gFD--_co+fRj2Jfuy=whEQvcBQ@mail.gmail.com>
	<1463575273.13625.23.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"egrumbach@gmail.com" <egrumbach@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: "Coelho, Luciano" <luciano.coelho@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463575273.13625.23.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2016 at 6:41 AM, Coelho, Luciano
<luciano.coelho@intel.com> wrote:
> On Wed, 2016-05-18 at 06:20 -0600, Reinoud Koornstra wrote:
>> On Wed, May 18, 2016 at 4:51 AM, Coelho, Luciano
>> <luciano.coelho@intel.com> wrote:
>> >
>> > Hi Emmanuel, Linus,
>> >
>> >
>> > On Wed, 2016-05-18 at 06:37 +0300, Emmanuel Grumbach wrote:
>> > >
>> > > On Wed, May 18, 2016 at 4:00 AM, Linus Torvalds
>> > > <torvalds@linux-foundation.org> wrote:
>> > > >
>> > > >
>> > > > On Tue, May 17, 2016 at 12:11 PM, David Miller <davem@davemloft
>> > > > .net
>> > > > >
>> > > > > wrote:
>> > > > >
>> > > > >
>> > > > > Highlights:
>> > > > Lowlights:
>> > > >
>> > > >  1) the iwlwifi driver seems to be broken
>> > > >
>> > > > My laptop that uses the intel 7680 iwlwifi module no longer
>> > > > connects
>> > > > to the network. It fails with a "Microcode SW error detected."
>> > > > and
>> > > > spews out register state over and over again.
>> > > Can we have the register state and the ASSERT / NMI / whatever
>> > > that
>> > > goes along with it?
>> > > This clearly means that the firmware is crashing, but I don't
>> > > know
>> > > why,
>> > > I copied here the lines that I need from another bug with another
>> > > device with another firmware,
>> > > but the log that we will still explain what I need:
>> > I managed to reproduce this bug locally with Linus' master.  I'm
>> > investigating the cause and I'll let you how it goes.
>> I did run the latest git code as well 4.6+
>> iwlwifi went pearshape in my case as well.
>> I just updated the microcode as well, it didn't matter.
>> 4.6-rc7 works fine and no errors are reported with iwlwifi.
>>
>> Here's output that might come in handy
>
> Thanks! That is helpful.
>
> Since you say that 4.6-rc7 works but 4.6 doesn't, the prime suspect is
> commit 5c08b0f5026f ("iwlwifi: mvm: don't override the rate with the
> AMSDU len"), which is the only iwlwifi patch between those two
> releases.
>
> Could you try to revert that and see if the error is gone?

Will do, since git revert failed I'll revert manually and report back.

>
> --
> Cheers,
> Luca.
