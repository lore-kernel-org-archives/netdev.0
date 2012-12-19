From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Wed, 19 Dec 2012 10:47:03 +0100
Message-ID: <50D18D17.4060502@6wind.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com> <87fw3boyxn.fsf@xmission.com> <50C8EEF0.2010201@6wind.com> <87zk1jht7d.fsf@xmission.com> <87sj7beyc1.fsf@xmission.com> <50CA135A.7060802@6wind.com> <87mwxh6a8y.fsf@xmission.com> <50CB5047.8060804@6wind.com> <87zk1g8tnq.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:59413 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702Ab2LSJxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 04:53:10 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so870335eek.5
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 01:53:09 -0800 (PST)
In-Reply-To: <87zk1g8tnq.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/12/2012 17:50, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 13/12/2012 20:08, Eric W. Biederman a =C3=A9crit :
>
>>> No.  The difficulty monitoring which network namespaces are being u=
sed
>>> is an unintended side effect.
>> Why is netlink a bad idea? Having a way to know all existing netns i=
s a start
>> point to monitor netns, isn't it?
>
> In the same way that having a neighbour table that contains all exist=
ing
> ip address to mac addresses mappings is a starting point to monitor a=
ll
> existing hosts.
>
> All does not scale.
>
> All removes a lot of perfectly valid use cases like checkpoint-restar=
t,
> and nesting containers.
>
> All as different from what is already implemented requires implementi=
ng
> yet another namespace to put the names of all into it.  We have enoug=
h
> namespaces now thank you very much.
>
> An unfiltered global list is about as interesting to use as putting
> all files in /.  Sure you know which directory you put your file in b=
ut
> which file is it?
>
> What has already been implemented should be roughly as good for
> monitoring as what is available with lsof.
>
> And of course there is the fact that a global list of anything that i=
s
> the same from every perspective violates the principle of relativity,
> and is in contradiction with the phsical reality in which we exist.
>
> So there is no way that having a global all inclusive list of network
> namespaces makes the least lick of sense and I really don't want to
> think about it.

Thank you for your explanations and your patience, this is very useful.


Nicolas
