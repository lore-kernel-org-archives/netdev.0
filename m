From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFT Patch net 2/2] ipv6: add a socket release callback for
 datagram sockets
Date: Thu, 24 Mar 2016 12:40:31 -0700
Message-ID: <CAM_iQpXqZyPXBq5L98Sgkaz3-LftboEtC111-VFNd+ENgC_c3w@mail.gmail.com>
References: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
	<1458847536-7729-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <weiwan@google.com>, Cong Wang <xiyou.wangcong@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:34521 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbcCXTkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 15:40:32 -0400
Received: by mail-yw0-f169.google.com with SMTP id h129so72467076ywb.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 12:40:31 -0700 (PDT)
In-Reply-To: <1458847536-7729-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 12:25 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> +       dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
> +       dst = !IS_ERR(rt) ? &rt->dst : NULL;

Oops, this one is clearly a copy-n-paste mistake...
