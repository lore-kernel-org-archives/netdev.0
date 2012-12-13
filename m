From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Thu, 13 Dec 2012 18:41:46 +0100
Message-ID: <50CA135A.7060802@6wind.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com> <87fw3boyxn.fsf@xmission.com> <50C8EEF0.2010201@6wind.com> <87zk1jht7d.fsf@xmission.com> <87sj7beyc1.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51052 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755731Ab2LMRlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 12:41:50 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so1247551bkw.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 09:41:49 -0800 (PST)
In-Reply-To: <87sj7beyc1.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2012 22:48, Eric W. Biederman a =C3=A9crit :
> ebiederm@xmission.com (Eric W. Biederman) writes:
>
>> It is very wrong to presume that without context you know the reason=
 for
>> the exsitence of any network namespace and that you should or even t=
hat
>> you can manage it.  Think of running your multi-network namespace
>> managing application in a container.
>
> A good example of a network namespace you don't want to mess with are
> the network namespaces created by vsftp and chrome for security purpo=
ses
> to remove any possibility of creating new connections to the network.
>
Ok, I get the point.

A last question: from an administration point of view, is it intended t=
o
not be able to monitor which netns are currently used? Like it can be d=
one
for sockets, files, ...
