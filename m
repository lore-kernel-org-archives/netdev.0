From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 14/29] net: vrf: Introduce vrf header file
Date: Fri, 06 Feb 2015 09:53:07 +0100
Message-ID: <54D480F3.8090105@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-15-git-send-email-dsahern@gmail.com> <54D373D0.40405@6wind.com> <54D41048.4050608@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:50991 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753446AbbBFIxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 03:53:10 -0500
Received: by mail-wi0-f177.google.com with SMTP id r20so713033wiv.4
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 00:53:08 -0800 (PST)
In-Reply-To: <54D41048.4050608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/02/2015 01:52, David Ahern a =C3=A9crit :
> On 2/5/15 6:44 AM, Nicolas Dichtel wrote:
>> Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
[snip]
>>> +#define VRF_ANY        0xffff
>> It could be useful to expose this value to userland.
>
> Maybe. I was thinking VRF_ANY should stay kernel side only and have a=
 sockopt
> value of -1 mean VRF_ANY.
Better to have a define instead of a magic value (-1) ;-)
