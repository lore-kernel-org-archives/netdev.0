From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 0/5] netns: allow to identify peer netns
Date: Wed, 02 Jul 2014 23:47:10 +0200
Message-ID: <53B47DDE.7@6wind.com>
References: <537327F1.4060603@6wind.com>	<1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com> <87simj7ca1.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:44893 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182AbaGBVrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 17:47:14 -0400
Received: by mail-wi0-f182.google.com with SMTP id bs8so1230479wib.3
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 14:47:13 -0700 (PDT)
In-Reply-To: <87simj7ca1.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/07/2014 22:09, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> The goal of this serie is to be able to multicast netlink messages w=
ith an
>> attribute that identify a peer netns.
>> This is needed by the userland to interpret some informations contai=
ned in
>> netlink messages (like IFLA_LINK value, but also some other attribut=
es in case
>> of x-netns netdevice (see also
>> http://thread.gmane.org/gmane.linux.network/315933/focus=3D316064)).
>>
>> Each network namespaces allocates its own ids for other netns (inclu=
ding
>> itself). The user can retrieve these ids via a new netlink messages,=
 but only
>> if he has a FD which points to this netns. Dump is not implemented s=
o that a
>> user cannot get the whole netns list.
>>
>> The goal of this RFC is mainly to validate the principle, ie patch 1=
/5 and 2/5.
>> Patch 3/5 and 4/5 shows an example of how to use these ids in rtnetl=
ink
>> messages. And patch 5/5 shows that the netlink messages can be symet=
ric between
>> a GET and a SET.
>
> This approach fundamentally breaks process migration, and calls for a
> namespace of namespaces.
Why does it call for a namespace of namespaces? Ids are different in ea=
ch netns,
because each netns has its own list id.
Can you elaborate why it breaks the process migration?

Do you think that identifying a netns from another netns is fundamental=
ly wrong?

Nicolas
