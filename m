From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sun, 5 Dec 2010 23:22:27 +0800
Message-ID: <AANLkTimLd=d94Cnh8dsX8HFFeYM4mBGH1gpK+p3YT-hm@mail.gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com> <4CFA3F01.20109@gmail.com>
 <1291472889.2159.18.camel@mojatatu> <1291474127.2159.35.camel@mojatatu>
 <20101204154007.GA1981@del.dom.local> <1291478881.2159.70.camel@mojatatu>
 <20101204165609.GB1981@del.dom.local> <AANLkTimnejoONxGqusiYVWOKbcy2yqbpFH-XyzgG0=87@mail.gmail.com>
 <AANLkTimMvb187gOFzZZgWuzWJkk_Z3AOZaoc6M76H-e=@mail.gmail.com>
 <1291559402.2159.687.camel@mojatatu> <AANLkTimXDTTNcrFPngzEuoDGVgojtBxUZQPOMiSA7yNw@mail.gmail.com>
 <1291562028.2159.692.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55661 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878Ab0LEPWt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 10:22:49 -0500
Received: by fxm20 with SMTP id 20so3545347fxm.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 07:22:48 -0800 (PST)
In-Reply-To: <1291562028.2159.692.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 5, 2010 at 11:13 PM, jamal <hadi@cyberus.ca> wrote:
> On Sun, 2010-12-05 at 22:40 +0800, Changli Gao wrote:
>> On Sun, Dec 5, 2010 at 10:30 PM, jamal <hadi@cyberus.ca> wrote:
>
>> > - we use tasklets. When we =A0reschedule we can end up on a differ=
rent
>> > cpu.
>>
>> The tasklets always been scheduled to the current CPU unless it has
>> been schedule already on the other CPU.
>
> I dont think this can be guaranteed - So the potential of packet
> reordering exists.
>

The current implementation can guarantee it. However, I can't find
documentation about this 'feature', but I think this behavior should
not be changed in future since maybe some call sites relay on it.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
