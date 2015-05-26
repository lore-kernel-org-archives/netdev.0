From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Tue, 26 May 2015 16:36:25 +0200
Message-ID: <556484E9.4040005@ahsoftware.de>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org> <555F969B.3090706@ahsoftware.de> <5562D315.9070405@6wind.com> <5562FFB0.40708@ahsoftware.de> <55631F22.90903@6wind.com> <55645097.5000509@ahsoftware.de> <556462A0.2020708@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:59693 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbbEZOgl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 10:36:41 -0400
Received: from wandq.ahsoftware (p4FC36136.dip0.t-ipconnect.de [79.195.97.54])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id 30B882C9C1D8
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 16:36:38 +0200 (CEST)
In-Reply-To: <556462A0.2020708@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 26.05.2015 um 14:10 schrieb Nicolas Dichtel:
> Le 26/05/2015 12:53, Alexander Holler a =C3=A9crit :
>> Am 25.05.2015 um 15:09 schrieb Nicolas Dichtel:
> [snip]
>>
>> Hmm, sounds like we're talking in different rooms about the same thi=
ng
>> in regard
>> to the dump. ;)
>>
>> I just wanted to explain why I think this series misses the (extende=
d)
>> dump
>> which includes all interfaces (those of other namespaces too).
> H=C3=A9h=C3=A9, I'm fully aware of the limitations, we move step by s=
tep but feel
> free to
> send a patch ;-)

I wasn't very successfull in sending kernel patches, so it would just b=
e=20
a waste of time (for me and anyone else).

> More seriously, I'm thinking to that problem but I did not start
> anything right
> now and I don't know when I will have time to do it.
> If I understand well, you are saying that this missing part is blocke=
r
> to use
> the new socket option. I don't agree with this. Doing a dump in an
> another netns
> is easy to do.
>
>>
>> How does one use NETLINK_LISTEN_ALL_NSID without beeing able to dump
>> all the
>> interfaces of namespaces your patch series might send messages for?
>>
>> The only way I currently see, is to start the listening part before =
any
>> namespace is created. Doing so, it can fill it's internal structures
>> with the
>> RTM_NEWLINK messages (besides that missing one for lo). But how do y=
ou
>> get these
>> RTM_NEWLINK messages for already created namespaces and their
>> interfaces, if not
>> by a dump?
> I don't understand why dumping in another netns is a problem.

It isn't. I just wondered how you (or someone else) is using=20
NETLINK_LISTEN_ALL_NSID, assuming it already serves a purpose. ;)

But your last sentence explained it.

Regards,

Alexander Holler
