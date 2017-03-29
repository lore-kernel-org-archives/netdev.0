From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Subject: Re: [PATCH] tcp: possible race between tcp_done() and tcp_poll()
Date: Thu, 30 Mar 2017 08:19:00 +0900
Message-ID: <3357c94d-fda9-1d3b-28f2-fe0fe2f82022@jp.fujitsu.com>
References: <34d952a3-77cd-ea53-c3e3-ccde91d5cf63@jp.fujitsu.com>
 <bf4e81fe-7213-8af5-4d5a-4bf2737eee7b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:48841 "EHLO
        mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932899AbdC2Xa5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 19:30:57 -0400
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
        by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id D50D2AC0124
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 08:19:41 +0900 (JST)
In-Reply-To: <bf4e81fe-7213-8af5-4d5a-4bf2737eee7b@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Sergei!

On 2017-03-29 20:57, Sergei Shtylyov wrote:
> Hello!
> 
> On 3/29/2017 8:22 AM, Seiichi Ikarashi wrote:
> 
>> Similar to commit a4d258036ed9b2a1811.
> 
>    Commit citing is standardized: it should specify 12-digit (at least) SHA1 and the commit summary line enclosed in ("").
> 
>> Between receiving a packet and tcp_poll(), sk->sk_err is protected by memory barriers but
>> sk->sk_shutdown and sk->sk_state are not. So possibly, POLLIN|POLLRDNORM|POLLRDHUP might
>> not be set even when receiving a RST packet.
>>
>> Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
>>
> 
>     Should be --- before the diffstat.

I'll resend.

Seiichi Ikarashi
