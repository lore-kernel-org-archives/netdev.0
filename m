From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH 1/2] netfilter/xt_hashlimit: new feature/algorithm for
 xt_hashlimit
Date: Mon, 4 Sep 2017 21:56:33 -0400
Message-ID: <a77a0537-4de1-1113-5492-7aee276c1f06@akamai.com>
References: <1503089939-15938-1-git-send-email-vpai@akamai.com>
 <20170904101433.GA3979@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
        johunt@akamai.com, fw@strlen.de, netdev@vger.kernel.org,
        pai.vishwain@gmail.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00190b01.pphosted.com ([67.231.157.127]:45244 "EHLO
        mx0b-00190b01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754070AbdIEB4z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 21:56:55 -0400
In-Reply-To: <20170904101433.GA3979@salvia>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2017 06:14 AM, Pablo Neira Ayuso wrote:
> Sounds good, applied, thanks.
> 
> A couple of questions: Does it really make sense to expose
> --hashlimit-rate-interval or are you using 1 second always there? I
> always wonder if it makes sense to expose yet another toggle that it's
> not clear to me how the user would take advantage from this.
> 
> Just curious here.


Thank you Pablo.

I generally just let rate-interval to default to 1, but I've added the
toggle to give the user more control on how often to sample the packet
rate. This wasn't an option before since we would always keep "delta" as
1 jiffy, but that is not the case in the new algorithm. Hence I have
exposed it as an option to the user.

Also, it looks like I broke the build on ARM and m68k arch. This is
because of the u64 division issue (sorry about that). I have sent
another patch to fix the problem "[PATCH] netfilter: xt_hashlimit: fix
64 bit division compile error". Please apply and send to net-next.

Thanks,
Vishwanath
