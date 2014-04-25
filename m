From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Fri, 25 Apr 2014 10:23:39 +0200
Message-ID: <535A1B8B.7030504@redhat.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com> <20140422.235745.1219194947074686642.davem@davemloft.net> <CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com> <20140423.125043.100674358164503915.davem@davemloft.net> <CAMEtUuwaEb5OgZHCYL-pJRrvLRWBqA1sXhg3diO3=K7ephyBpA@mail.gmail.com> <1398289142.29914.23.camel@edumazet-glaptop2.roam.corp.google.com> <CAMEtUuy-n4=YxejsCF0gg2VX1csfW5p8SfwggH2Tzi6XvE_htw@mail.gmail.com> <1398308109.29914.61.camel@edumazet-glaptop2.roam.corp.google.com> <CAMEtUuy-GoRouDJMHRLEpiAxG2mXnPiwiZY6j9eGTnuRvzmh-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811AbaDYIXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2014 04:23:51 -0400
In-Reply-To: <CAMEtUuy-GoRouDJMHRLEpiAxG2mXnPiwiZY6j9eGTnuRvzmh-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2014 05:22 AM, Alexei Starovoitov wrote:
...
>> net/core/filter.c was about 880 lines in previous release, its now 1800+
>> lines.
>
> but the whole sk_encode/decode functions are obsolete.
> Now we can remove some code too.

Indeed, these can eventually be removed; naturally, a bigger portion
of these changes go into the conversion functions into the new layout.
The interpreter part itself is conceptually the same, seccomp as you
might have noticed actually got a lot easier thanks to the BPF
changes, and the new instruction layout is much easier to handle for
JITs (i.e. the BPF extensions), which is ongoing work. Clearly, there
are successive integration steps required. As such, also the
documentation will get further improved for all that in the next days.

Thanks,

Daniel
