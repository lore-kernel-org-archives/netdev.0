From: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 15:35:40 +0100
Message-ID: <514331BC.4080802@hhi.fraunhofer.de>
References: <513F1A17.1000809@hhi.fraunhofer.de> <CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com> <3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de> <87r4jjav00.fsf@xmission.com> <3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de> <878v5r9es7.fsf@xmission.com> <5142CE23.9070804@hhi.fraunhofer.de> <87ip4t598t.fsf@xmission.com> <514326FF.6020205@hhi.fraunhofer.de> <CAFLxGvwvH_krBDJ2i-si1LX2SKbeeRmXGR+0ZbtEB2oKWt-GoA@mail.gmail.com> <51432B72.20408@hhi.fraunhofer.de> <CAFLxGvyCFHk=vhNYCY8obrVJR2rW9M7+J_ppyVpFq3AHAxjRjA@mail.gmail.com> <51432E13.5060003@hhi.fraunhofer.de> <CAFLxGvyDaaOtm1TrD-gfvhja_Uow8jtRbPyb2WcMscSLgo1umg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:42727 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607Ab3COOff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 10:35:35 -0400
In-Reply-To: <CAFLxGvyDaaOtm1TrD-gfvhja_Uow8jtRbPyb2WcMscSLgo1umg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.03.2013 15:32, schrieb richard -rw- weinberger:
> On Fri, Mar 15, 2013 at 3:20 PM, Thomas Martitz
> <thomas.martitz@hhi.fraunhofer.de> wrote:
>>> The real question is, why do you need a second one?
>>> I assume your driver (for the non-existing hardware) is a ethernet driver,
>>> and now you're looking for a way to test your shiny new ethX device,
>>> correct?
>>>
>>
>> Yes. But that's only the first step. Once I have the basic ethX device
>> working I want to make sure the PCIe data transfer is working (with good
>> performance), ideally using the very same test application in user space.
>
> And there is the second loopback device is this picture?
>

Mine is the second one, as I cannot modify "lo". The standard "lo" 
interface is the the first loopback and it seems to be hardcoded to be 
the only one.

Best regards.

-----
visit us at

OFC 2013 / March 19-21 / Anaheim Convention Center, CA, USA / booth 11807

NABSHOW 2013 / April 8-11 / Las Vegas Convention Center, Nevada, USA / booth C7843

www.hhi.fraunhofer.de/events
