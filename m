From: Arnaud Lacombe <lacombar@gmail.com>
Subject: Re: [PATCH v1 2/2] TCPCT API sockopt update to draft -03
Date: Thu, 13 Jan 2011 12:53:17 -0500
Message-ID: <AANLkTinhnaF3-scKnTOC5rF68+5otVW2NG3v1y80L0k6@mail.gmail.com>
References: <4D2DE824.10205@gmail.com>
	<4D2DEC0A.70608@gmail.com>
	<20110112105608.793787b2@s6510>
	<4D2F3723.9040405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45601 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933073Ab1AMRxS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 12:53:18 -0500
In-Reply-To: <4D2F3723.9040405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Jan 13, 2011 at 12:32 PM, William Allen Simpson
<william.allen.simpson@gmail.com> wrote:
> On 1/12/11 1:56 PM, Stephen Hemminger wrote:
>>
>> On Wed, 12 Jan 2011 12:59:38 -0500
>> William Allen Simpson<william.allen.simpson@gmail.com> =A0wrote:
>>
>>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>>> index e64f4c6..c8f4017 100644
>>> --- a/include/linux/tcp.h
>>> +++ b/include/linux/tcp.h
>>> @@ -185,22 +185,37 @@ struct tcp_md5sig {
>>> =A0#define TCP_COOKIE_PAIR_SIZE =A0(2*TCP_COOKIE_MAX)
>>>
>>> =A0/* Flags for both getsockopt and setsockopt */
>>> -#define TCP_COOKIE_IN_ALWAYS =A0 (1<< =A00) =A0 =A0 =A0 =A0/* Disc=
ard SYN without
>>> cookie */
>>> -#define TCP_COOKIE_OUT_NEVER =A0 (1<< =A01) =A0 =A0 =A0 =A0/* Proh=
ibit outgoing
>>> cookies,
>>> +#define TCPCT_IN_ALWAYS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<< =A00) =
=A0 =A0 =A0 =A0/* Discard SYN
>>> without cookie */
>>> +#define TCPCT_OUT_NEVER =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<< =A01) =
=A0 =A0 =A0 =A0/* Prohibit
>>> outgoing cookies,
>>
>> You end up changing values in kernel userspace API in a way
>> that is incompatible with older applications. This is not acceptable=
=2E
>>
> While I agree in principle and argued strongly against it, other
> members of the research group (particularly the original project
> sponsor) have over-ridden my concerns. =A0I'm sorry to inform you tha=
t
> many/most participants don't care much about Linux.
>
> Note that the *bits* are the same, and previously compiled programs
> (that don't access more advanced features) should continue to run as
> they have in the past.
>
> Even though I'm not paid to work on Linux, I'm doing my best to give =
you
> folks a quick heads up and provide code to rectify the very recent ch=
anges
> that can be propagated back through the stable tree (to 2.6.33).
>
> As always, what you actually do with my code is up to you....
>
=46WIW, what is the basis of this hunk ? The RFC text[0] seems to use
the TCP_COOKIE_* naming, not TCPCT_.

Thanks,
 - Arnaud

[0]: http://www.rfc-editor.org/authors/rfc6013.txt

--
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
