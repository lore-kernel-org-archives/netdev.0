From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next v3] tcp: add rfc3168, section 6.1.1.1. fallback
Date: Wed, 20 May 2015 11:13:08 -0700
Message-ID: <CAGK4HS_U5Me2ubi-QPaceLiw-ZU7P9Q=ZOSpgg6SRqn-fA2Gaw@mail.gmail.com>
References: <cc0be24818d7009208dd0d8f73cc35939957f134.1432059419.git.daniel@iogearbox.net>
	<20150519.165400.818177627516799715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	netdev <netdev@vger.kernel.org>, fw@strlen.de,
	mirja.kuehlewind@tik.ee.ethz.ch, trammell@tik.ee.ethz.ch,
	Eric Dumazet <edumazet@google.com>,
	Dave Taht <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:36696 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754209AbbETSNJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:13:09 -0400
Received: by yhrr66 with SMTP id r66so15107874yhr.3
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:13:08 -0700 (PDT)
In-Reply-To: <20150519.165400.818177627516799715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

With this commit, ifconfig does not show any of the interfaces and I
don't have any connectivity as a result.
Can you double check this?

Thanks!
Vijay

On 19 May 2015 at 13:54, David Miller <davem@davemloft.net> wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Tue, 19 May 2015 21:33:42 +0200
>
>> This work as a follow-up of commit f7b3bec6f516 ("net: allow setting=
 ecn
>> via routing table") and adds RFC3168 section 6.1.1.1. fallback for o=
utgoing
>> ECN connections. In other words, this work adds a retry with a non-E=
CN
>> setup SYN packet, as suggested from the RFC on the first timeout:
>>
>>   [...] A host that receives no reply to an ECN-setup SYN within the
>>   normal SYN retransmission timeout interval MAY resend the SYN and
>>   any subsequent SYN retransmissions with CWR and ECE cleared. [...]
>  ...
>> Reference: https://www.ietf.org/proceedings/92/slides/slides-92-iccr=
g-1.pdf
>> Reference: https://www.ietf.org/proceedings/89/slides/slides-89-tsva=
rea-1.pdf
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> Signed-off-by: Florian Westphal <fw@strlen.de>
>> Signed-off-by: Mirja K=C3=BChlewind <mirja.kuehlewind@tik.ee.ethz.ch=
>
>> Signed-off-by: Brian Trammell <trammell@tik.ee.ethz.ch>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Dave T=C3=A4ht <dave.taht@gmail.com>
>> ---
>>  v2 -> v3:
>>   - Very sorry. Typo happened in Dave's name since v1, getting it ri=
ght
>>     this time, no bad intentions. ;)
>>  v1 -> v2:
>>   - Added suggestion from Eric to let ecn_flags be cleared eventuall=
y in
>>     tcp_ecn_rcv_synack(), thanks!
>>   - Rest as is.
>
> Applied, thanks everyone.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
