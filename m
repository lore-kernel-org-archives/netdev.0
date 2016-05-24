From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2 1/1] tc simple action: bug fix
Date: Tue, 24 May 2016 07:43:50 -0400
Message-ID: <57443E76.2050608@mojatatu.com>
References: <1464051893-25680-1-git-send-email-jhs@emojatatu.com>
 <57442D40.4040905@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35943 "EHLO
	mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbcEXLny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 07:43:54 -0400
Received: by mail-it0-f44.google.com with SMTP id e62so49251301ita.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 04:43:54 -0700 (PDT)
In-Reply-To: <57442D40.4040905@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-24 06:30 AM, Daniel Borkmann wrote:
> On 05/24/2016 03:04 AM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Failed compile
>> m_simple.c: In function =E2=80=98parse_simple=E2=80=99:
>> m_simple.c:154:6: warning: too many arguments for format
>> [-Wformat-extra-args]
>>        *argv);
>>        ^
>> m_simple.c:103:14: warning: unused variable =E2=80=98maybe_bind=E2=80=
=99
>> [-Wunused-variable]
>
> Btw, that last one is still not addressed.

Sigh. It is fixed in my tree. I have a few of patches that
I was planning to send later and some are touching intersecting files
and i am trying to be clever with git. Any tips? ;->
Will send v2.

cheers,
jamal
