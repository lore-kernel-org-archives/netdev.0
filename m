From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next 0/5] replace skb tc_verd member with 3 dedicated
 bit flags
Date: Tue, 05 May 2015 09:22:38 -0400
Message-ID: <5548C41E.5020308@mojatatu.com>
References: <1430765318-13788-1-git-send-email-fw@strlen.de> <5548ABF8.5080806@mojatatu.com> <20150505114733.GE17061@breakpoint.cc> <5548B070.80502@mojatatu.com> <5548B984.5000900@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36077 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422884AbbEENXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 09:23:12 -0400
Received: by oift201 with SMTP id t201so147570765oif.3
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 06:23:11 -0700 (PDT)
In-Reply-To: <5548B984.5000900@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/15 08:37, Daniel Borkmann wrote:
> On 05/05/2015 01:58 PM, Jamal Hadi Salim wrote:


>
> ... I quite frankly find the transformation after Florian's series
> *MUCH*, *MUCH* more intuitive, also given that we use such kind of
> bit flags already extensively everywhere in else the stack.
>

But he has to go around and change all occurrences where the macros are
invoked.
In some cases nothing has changed; in such a case the macros are useful
for hiding what goes on.
In any case - this is not as a big issue.

> What's more is that we reduce skbuff usage by 13-12 bits (given the
> follow up fix with AT_STACK is addressed).
>

Thats an orthogonal issue. Those bits were useful a few years ago,
and the use cases didnt pan out. So iam not against getting recycling.


> I think that can be done as a follow-up *after* the series.

Sure. Would of course be better to do it in this series if changes
are going to be made.

> Given
> it's uapi (which probably never should have been?) it's a different
> question on its own.
>
> Looking at git log include/uapi/linux/pkt_cls.h, it slipped in via
> David Howells uapi script ...
>
> commit 607ca46e97a1b6594b29647d98a32d545c24bdff
> Author: David Howells <dhowells@redhat.com>
> Date:   Sat Oct 13 10:46:48 2012 +0100
>

Should never have been in uapi.
I dont think i saw that submission you pointed to.
But the problem may have existed before that patch.

cheers,
jamal
