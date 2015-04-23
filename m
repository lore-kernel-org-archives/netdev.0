From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 11:30:33 -0700
Message-ID: <CAHA+R7PoJjcwiTBJC5BLSRTeMprbNkuojAyOHjqMw46+L=mAnA@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-3-git-send-email-ast@plumgrid.com>
	<CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>
	<55381F14.4070708@plumgrid.com>
	<CAHA+R7Mz0LSZ-S=k7rvUuhXm+GT9w2ve6Ug+YPJ4vqnsrLnfpw@mail.gmail.com>
	<55385D0B.5030103@plumgrid.com>
	<CAHA+R7N0w0gSVRrxchzHoYHV6=ubs7m1CW6G+e-G3+sBbnz+yQ@mail.gmail.com>
	<5539381D.8030501@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38744 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030509AbbDWSae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:30:34 -0400
Received: by wiun10 with SMTP id n10so102231899wiu.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 11:30:33 -0700 (PDT)
In-Reply-To: <5539381D.8030501@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2015 at 11:21 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 04/23/2015 08:12 PM, Cong Wang wrote:
>>
>> On Wed, Apr 22, 2015 at 7:46 PM, Alexei Starovoitov <ast@plumgrid.com>
>> wrote:
>
> ...
>>>
>>> TC_ACT_QUEUED cannot be removed.
>>> Only deprecated with backwards compatibility the way this patch did it.
>>> That should have been obvious.
>>
>>
>> It is at least the third time I have to repeat that: we really don't care
>> about out-of-tree modules.
>>
>> Everyone MUST read Documentation/stable_api_nonsense.txt.
>
>
> Seriously, what are you talking about ???
>
> $ git grep -n TC_ACT_QUEUED include/uapi/
> include/uapi/linux/pkt_cls.h:105:#define TC_ACT_QUEUED          5
>
> This is *UAPI*, no-one is even remotely talking about out-of-tree
> kernel modules.

I am not stupid. You should figure out we can just leave its definition
by removing it, leaving the default as stolen.
