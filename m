From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Tue, 29 Apr 2014 09:18:41 -0500
Message-ID: <CAHrpEqRZ1oyd6bXXqxznfw+1qwo5LVBW10mcrzLbbCHYowPetA@mail.gmail.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
	<1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
	<CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:33539 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbaD2OSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:18:42 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so288070wgh.2
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 07:18:41 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 9:01 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Frank ...
>> > You probably want the read and write indexes as well.
>>
>>                      bdp == fep->cur_tx ? 'S' : ' ',
>>                      bdp == fep->dirty_tx ? 'H' : ' ',
>>
>> Above code already print read and write index. 'S', 'H'
>
> Gah I must be asleep!
> Something made be think that was to do with the ring ownership bit!

I think it is same thing. If I am wrong, please tell me difference.

>
>         David
>
