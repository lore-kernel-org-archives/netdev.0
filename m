From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of pkt_type_offset
Date: Fri, 12 Sep 2014 22:48:17 +0200
Message-ID: <54135C11.1010201@redhat.com>
References: <5412D9B9.2020300@redhat.com> <3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644AbaILUsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 16:48:38 -0400
In-Reply-To: <3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 02:04 PM, Hannes Frederic Sowa wrote:
> Currently we have 2 pkt_type_offset functions doing the same thing and
> spread across the architecture files. Remove those and replace them
> with a PKT_TYPE_OFFSET macro helper which gets the constant value from a
> zero sized sk_buff member right in front of the bitfield with offsetof.
> This new offset marker does not change size of struct sk_buff.
>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Markos Chandras <markos.chandras@imgtec.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good to me, thanks!

Acked-by: Daniel Borkmann <dborkman@redhat.com>
