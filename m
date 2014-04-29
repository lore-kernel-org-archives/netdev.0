From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Tue, 29 Apr 2014 09:54:09 -0500
Message-ID: <CAHrpEqQL7LviXA4_NLNwSBoW84W_vbnzWkc9At5QBqUkqu63yw@mail.gmail.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
	<1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
	<CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
	<20140429141527.GZ26756@n2100.arm.linux.org.uk>
	<CAHrpEqTc6=yS4ApLO7AbZyVq26kGxq+WBcyFjgjbiPySq7055Q@mail.gmail.com>
	<20140429143243.GA26756@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Frank Li <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:45737 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757703AbaD2OyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:54:11 -0400
Received: by mail-wi0-f171.google.com with SMTP id bs8so1369596wib.16
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 07:54:09 -0700 (PDT)
In-Reply-To: <20140429143243.GA26756@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 9:32 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Tue, Apr 29, 2014 at 09:22:13AM -0500, Frank Li wrote:
>> On Tue, Apr 29, 2014 at 9:15 AM, Russell King - ARM Linux
>> <linux@arm.linux.org.uk> wrote:
>> > On Tue, Apr 29, 2014 at 02:01:54PM +0000, David Laight wrote:
>> >> From: Frank ...
>> >> > > You probably want the read and write indexes as well.
>> >> >
>> >> >                      bdp == fep->cur_tx ? 'S' : ' ',
>> >> >                      bdp == fep->dirty_tx ? 'H' : ' ',
>> >> >
>> >> > Above code already print read and write index. 'S', 'H'
>> >>
>> >> Gah I must be asleep!
>> >> Something made be think that was to do with the ring ownership bit!
>> >
>> > Err, what's going on... this is my patch.  If it's been submitted by
>> > others, why wasn't its submission at least Cc'd to me?
>>
>> I added " --to rmk+kernel@arm.linux.org.uk" when I send patch.
>> I don't know what's wrong.
>
> Yes... I guess you don't know what went wrong because you'll never know
> if it failed to be delivered, because you sent them with an envelope
> address of "b20596@shlinux1.ap.freescale.net" which doesn't actually
> exist.  Therefore, DSNs can't be returned to you.
>
>> I ask you if need someone help send to david millar before.
>
> You did, but I didn't agree to it.  I did point out that they need a
> certain amount of rework first:

Sorry, I miss understood your means.
I will stop working on this.

Actually, we want to upstream imx6 SoloX enet.
Solox have not more features, like AVB.

If we upstream base on David's tree, there will be big conflict what
you already done.

best regards
Frank Li

>
>   I know they need to re-worked to convert unsigned -> unsigned int before
>   David sees them, otherwise it'd be an instant review failure.  Doing the
>   conversion is the easy bit, doing it without hitting the 80 column limit
>   is much harder...
>
> Some of them need a little more work in addition to that before being
> sent to David.
>
> I've also subsequently received in private email one issue which indicates
> a problem with the patch set - as yet I've not been able to look at it,
> but it sounds like the RX ring is full, but NAPI is in hard-irq mode,
> and the hardware won't deliver an IRQ without free space in the RX ring.
>
> Since people have got wind that I've been looking at this driver, everyone
> has started sending their various FEC issues directly to me...
>
> --
> FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
> improving, and getting towards what was expected from it.
