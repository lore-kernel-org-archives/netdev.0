From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 net-next 2/7] tcp: do not block bh during prequeue
 processing
Date: Fri, 29 Apr 2016 14:47:34 -0700
Message-ID: <5723D676.30601@fb.com>
References: <1461964613-4872-1-git-send-email-edumazet@google.com>
 <1461964613-4872-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:28074 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752295AbcD2Vri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 17:47:38 -0400
In-Reply-To: <1461964613-4872-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/16 2:16 PM, Eric Dumazet wrote:
> AFAIK, nothing in current TCP stack absolutely wants BH
> being disabled once socket is owned by a thread running in
> process context.
>
> As mentioned in my prior patch ("tcp: give prequeue mode some care"),
> processing a batch of packets might take time, better not block BH
> at all.
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh<soheil@google.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
