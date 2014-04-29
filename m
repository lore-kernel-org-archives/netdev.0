From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Tue, 29 Apr 2014 09:30:51 -0500
Message-ID: <CAHrpEqQ62O=C7eMQbgpSNQ_Kh8rD6-ERL4j2vkJOuGvZuE=L2g@mail.gmail.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
	<1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
	<CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
	<20140429141527.GZ26756@n2100.arm.linux.org.uk>
	<CAHrpEqTc6=yS4ApLO7AbZyVq26kGxq+WBcyFjgjbiPySq7055Q@mail.gmail.com>
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
Received: from mail-we0-f179.google.com ([74.125.82.179]:55623 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbaD2Oaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:30:52 -0400
Received: by mail-we0-f179.google.com with SMTP id x48so291122wes.24
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 07:30:51 -0700 (PDT)
In-Reply-To: <CAHrpEqTc6=yS4ApLO7AbZyVq26kGxq+WBcyFjgjbiPySq7055Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 9:22 AM, Frank Li <lznuaa@gmail.com> wrote:
> On Tue, Apr 29, 2014 at 9:15 AM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
>> On Tue, Apr 29, 2014 at 02:01:54PM +0000, David Laight wrote:
>>> From: Frank ...
>>> > > You probably want the read and write indexes as well.
>>> >
>>> >                      bdp == fep->cur_tx ? 'S' : ' ',
>>> >                      bdp == fep->dirty_tx ? 'H' : ' ',
>>> >
>>> > Above code already print read and write index. 'S', 'H'
>>>
>>> Gah I must be asleep!
>>> Something made be think that was to do with the ring ownership bit!
>>
>> Err, what's going on... this is my patch.  If it's been submitted by
>> others, why wasn't its submission at least Cc'd to me?
>
> I added " --to rmk+kernel@arm.linux.org.uk" when I send patch.
> I don't know what's wrong.
> I kept your name.
>
> I ask you if need someone help send to david millar before.

I found the reason.
Your email in MAINTAINS is
Russell King <linux@arm.linux.org.uk>

But signed off in your original patch is
Russell King <rmk+kernel@arm.linux.org.uk>

Which one should be kept in patch?

>
>>
>> --
>> FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
>> improving, and getting towards what was expected from it.
