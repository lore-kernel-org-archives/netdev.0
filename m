From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Fri, 14 Dec 2012 17:13:59 +0100
Message-ID: <50CB5047.8060804@6wind.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com> <87fw3boyxn.fsf@xmission.com> <50C8EEF0.2010201@6wind.com> <87zk1jht7d.fsf@xmission.com> <87sj7beyc1.fsf@xmission.com> <50CA135A.7060802@6wind.com> <87mwxh6a8y.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:59599 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605Ab2LNQOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 11:14:05 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1367749eaa.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 08:14:03 -0800 (PST)
In-Reply-To: <87mwxh6a8y.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/12/2012 20:08, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 12/12/2012 22:48, Eric W. Biederman a =C3=A9crit :
>>> ebiederm@xmission.com (Eric W. Biederman) writes:
>>>
>>>> It is very wrong to presume that without context you know the reas=
on for
>>>> the exsitence of any network namespace and that you should or even=
 that
>>>> you can manage it.  Think of running your multi-network namespace
>>>> managing application in a container.
>>>
>>> A good example of a network namespace you don't want to mess with a=
re
>>> the network namespaces created by vsftp and chrome for security pur=
poses
>>> to remove any possibility of creating new connections to the networ=
k.
>>>
>> Ok, I get the point.
>>
>> A last question: from an administration point of view, is it intende=
d to
>> not be able to monitor which netns are currently used? Like it can b=
e done
>> for sockets, files, ...
>
> No.  The difficulty monitoring which network namespaces are being use=
d
> is an unintended side effect.
Why is netlink a bad idea? Having a way to know all existing netns is a=
 start
point to monitor netns, isn't it?

>
> My pending changes to /proc/<pid>/ns/net and friends that allow you t=
o
> stat those files and compare if two network are the same network
> namespace should make that monitoring much easier.  It isn't perfect =
as
> there currently isn't a way to take a socket and say which network
> namespace is this socket in.  But the current solution should tell yo=
u
> what is happening most of the time.
Yes, this will give interessing infos.

> struct net allocates it's own slab type so /proc/slabinfo on a good d=
ay
> can tell you how many network namespace structures have been allocate=
d
> and are in use.
Ok.

Nicolas
