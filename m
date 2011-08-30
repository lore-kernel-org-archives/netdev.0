From: "J.Hwan Kim" <frog1120@gmail.com>
Subject: Re: Unicast hash for IXGBEVF driver
Date: Tue, 30 Aug 2011 10:05:47 +0900
Message-ID: <4E5C376B.1030907@gmail.com>
References: <4E589B69.7020305@gmail.com> <CAL3LdT6UBxEgjEX0MMCRmnXw2243nq5GyvYtQ9JOdGRtnsHS6g@mail.gmail.com> <43F901BD926A4E43B106BF17856F0755019454265E@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:42188 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab1H3BFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 21:05:51 -0400
Received: by pzk37 with SMTP id 37so9380475pzk.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2011 18:05:51 -0700 (PDT)
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019454265E@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011=EB=85=84 08=EC=9B=94 30=EC=9D=BC 03:24, Rose, Gregory V wrote:
> The ROPE bits should not be set for any of the VFs and only on the PF=
 when it is in promiscuous mode.
>
> The PFUTA bits are imperfect MAC address hash filters.  By setting th=
em all to ones and then turning on the ROPE bit for each of the VFs you=
're essentially putting the VF into a sort of fake promiscuous mode.
>
> This is not recommended.  Older drivers that did this had a bug in th=
em.
>
> - Greg

Hi, Greg,
Thank you for reply.
When I have two streams of which destination mac address, for example=20
34:22:11:13:23:55 and 14:12:34:23:12:33,
and I have 2VFs, how can I set the PFUTA register for distributting the=
=20
streams into 2VFs according to the MAC address?
I want to first MAC address stream to first VF and second MAC address=20
stream to second VF.



>> -----Original Message-----
>> From: tarbal@gmail.com [mailto:tarbal@gmail.com] On Behalf Of Jeff K=
irsher
>> Sent: Saturday, August 27, 2011 12:35 AM
>> To: J.Hwan Kim; Rose, Gregory V
>> Cc: netdev; e1000-devel@lists.sourceforge.net
>> Subject: Re: Unicast hash for IXGBEVF driver
>>
>> On Sat, Aug 27, 2011 at 00:23, J.Hwan Kim<frog1120@gmail.com>  wrote=
:
>>> Hi, everyone
>>>
>>> How can I distribute the packets according to destination MAC addre=
ss
>>> into multi-virtual fucntion queue?
>>> Now, my setting is that all bit of PFUTA are '1' and ROPE bit is 1,
>>> so all mac packet is duplicated to all VF queue.
>>> I cannot understand the meaning of bits of PFUTA and the relation
>>> with mac address.
>>> I want to distribute the received packets to RX queues respectively=
,
>>> not duplicated.
>>>
>>>
>>> Thanks in advance.
>>>
>>> Best Regards,
>>> J.Hwan Kim
>>>
>> Adding Greg Rose, since he is the ixgbevf driver maintainer.  He
>> should be able to answer your questions early next week, unless he i=
s
>> checking his email over the weekend.
>>
>> --
>> Cheers,
>> Jeff
