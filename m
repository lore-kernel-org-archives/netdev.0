From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic
Date: Tue, 13 Aug 2013 16:37:04 +0800
Message-ID: <5209F030.3050303@windriver.com>
References: <1375772225-19265-1-git-send-email-fan.du@windriver.com> <20130806092220.GH25511@secunet.com> <52087537.6060200@windriver.com> <20130813075519.GN25511@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60153 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab3HMIeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 04:34:03 -0400
In-Reply-To: <20130813075519.GN25511@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8813=E6=97=A5 15:55, Steffen Klassert wrote:
> On Mon, Aug 12, 2013 at 01:40:07PM +0800, Fan Du wrote:
>>
>>
>> On 2013=E5=B9=B408=E6=9C=8806=E6=97=A5 17:22, Steffen Klassert wrote=
:
>>> On Tue, Aug 06, 2013 at 02:57:05PM +0800, Fan Du wrote:
>>>> xfrm_state timer should be independent of system clock change,
>>>> so switch to monotonic clock base.
>>>>
>>>
>>> I think a monotonic timer will reintroduce a bug on suspend/resume
>>> that was fixed by commit 9e0d57fd6
>>> (xfrm: SAD entries do not expire correctly after suspend-resume)
>>>
>>> Please make sure that this does not happen.
>>
>> What about using CLOCK_BOOTTIME? it's monotonic, but includes suspen=
d time as well.
>
> As I said, I'm open to everything that fixes your problem and does no=
t
> introduce a regression. I'll consider applying after some testing
> if noone else has objections.

Hi, Steffen

Thanks for your understanding! :)

I happened to bump into CLOCK_BOOTTIME several days ago, so apologize f=
or
eating my words earlier. Changing xfrm_state timer to monotonic does no=
t
solve the problem I've described earlier in:

http://www.spinics.net/lists/netdev/msg245019.html (*1*)

So is there any light of hope for the proposal in (*1*) by using CLOCK_=
BOOTTIME
instead?


> Thanks!
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
