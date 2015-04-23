From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 20:21:17 +0200
Message-ID: <5539381D.8030501@iogearbox.net>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com>	<CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>	<55381F14.4070708@plumgrid.com>	<CAHA+R7Mz0LSZ-S=k7rvUuhXm+GT9w2ve6Ug+YPJ4vqnsrLnfpw@mail.gmail.com>	<55385D0B.5030103@plumgrid.com> <CAHA+R7N0w0gSVRrxchzHoYHV6=ubs7m1CW6G+e-G3+sBbnz+yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41871 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030339AbbDWSVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:21:25 -0400
In-Reply-To: <CAHA+R7N0w0gSVRrxchzHoYHV6=ubs7m1CW6G+e-G3+sBbnz+yQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2015 08:12 PM, Cong Wang wrote:
> On Wed, Apr 22, 2015 at 7:46 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
...
>> TC_ACT_QUEUED cannot be removed.
>> Only deprecated with backwards compatibility the way this patch did it.
>> That should have been obvious.
>
> It is at least the third time I have to repeat that: we really don't care
> about out-of-tree modules.
>
> Everyone MUST read Documentation/stable_api_nonsense.txt.

Seriously, what are you talking about ???

$ git grep -n TC_ACT_QUEUED include/uapi/
include/uapi/linux/pkt_cls.h:105:#define TC_ACT_QUEUED          5

This is *UAPI*, no-one is even remotely talking about out-of-tree
kernel modules.
