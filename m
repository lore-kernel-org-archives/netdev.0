From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] tc: fix bpf compilation with old glibc
Date: Wed, 22 Jul 2015 15:18:53 +0200
Message-ID: <55AF983D.7080507@6wind.com>
References: <1437568170-16995-1-git-send-email-nicolas.dichtel@6wind.com> <55AF951C.8030106@iogearbox.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34724 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932905AbbGVNS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:18:56 -0400
Received: by wibud3 with SMTP id ud3so153858292wib.1
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 06:18:55 -0700 (PDT)
In-Reply-To: <55AF951C.8030106@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/07/2015 15:05, Daniel Borkmann a =E9crit :
> On 07/22/2015 02:29 PM, Nicolas Dichtel wrote:
>> Error was:
>> f_bpf.o: In function `bpf_parse_opt':
>> f_bpf.c:(.text+0x88f): undefined reference to `secure_getenv'
>> m_bpf.o: In function `parse_bpf':
>> m_bpf.c:(.text+0x587): undefined reference to `secure_getenv'
>> collect2: error: ld returned 1 exit status
>>
>> CC: Daniel Borkmann <daniel@iogearbox.net>
>> Fixes: 88eea5395483 ("tc: {f,m}_bpf: allow to retrieve uds path from=
 env")
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Thanks Nicolas! I am thinking we should probably just stick to getenv=
()
> and convert these two users.
As you want, I don't have a strong opinion on this. Stephen?


Regards,
Nicolas
