From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: do xfrm transform after nat if necessary
Date: Tue, 4 Nov 2014 09:14:15 +0800
Message-ID: <54582867.5020809@cn.fujitsu.com>
References: <54570A2F.2070206@cn.fujitsu.com> <20141103.144234.1037182010018495486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:30124 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750873AbaKDBQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 20:16:21 -0500
In-Reply-To: <20141103.144234.1037182010018495486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2014 03:42 AM, David Miller wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Date: Mon, 3 Nov 2014 12:53:03 +0800
> 
>>
>>
>> In function nf_nat_ipv6_out, after nat is done, nf_xfrm_me_harder()
>> will be called to look up xfrm dst.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> This is far from sufficient of a commit log message for a change that
> is as serious and has as many implications as this one.
> 
> You haven't answered many questions, first of which in my mind is
> why we are bypassing all of the fragmentation checks?
> 
> We're also bypassing ip6_finish_output2() which does multicast and
> hooks up the neighbour.
> 
> IPV4 doesn't do this, why doesn't it have the same supposed problem
> you are trying to solve?
> 
> It is not even clear to me what the problem is, because your commit
> message is way too terse.
> 
Thank you for your advice, I would consider a more comprehensive 
of the problem.

Thanks,
  Duan
