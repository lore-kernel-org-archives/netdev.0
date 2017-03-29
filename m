From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] tcp: possible race between tcp_done() and tcp_poll()
Date: Wed, 29 Mar 2017 14:57:49 +0300
Message-ID: <bf4e81fe-7213-8af5-4d5a-4bf2737eee7b@cogentembedded.com>
References: <34d952a3-77cd-ea53-c3e3-ccde91d5cf63@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33681 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754661AbdC2L5w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 07:57:52 -0400
Received: by mail-lf0-f43.google.com with SMTP id h125so6515320lfe.0
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 04:57:50 -0700 (PDT)
In-Reply-To: <34d952a3-77cd-ea53-c3e3-ccde91d5cf63@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 3/29/2017 8:22 AM, Seiichi Ikarashi wrote:

> Similar to commit a4d258036ed9b2a1811.

    Commit citing is standardized: it should specify 12-digit (at least) SHA1 
and the commit summary line enclosed in ("").

> Between receiving a packet and tcp_poll(), sk->sk_err is protected by memory barriers but
> sk->sk_shutdown and sk->sk_state are not. So possibly, POLLIN|POLLRDNORM|POLLRDHUP might
> not be set even when receiving a RST packet.
>
> Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
>

     Should be --- before the diffstat.

>  net/ipv4/tcp.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)

[...]

MBR, Sergei
