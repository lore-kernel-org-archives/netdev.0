From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Fri, 18 Mar 2016 11:10:04 -0700
Message-ID: <CAM_iQpXgHHr=h=3VeMdYfOnzTdeBeODGVKmwBi7AFW485_WRAg@mail.gmail.com>
References: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
	<20160316.195341.68257764618999441.davem@davemloft.net>
	<1458174127.7353.11.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160316.223803.240230703927987310.davem@davemloft.net>
	<1458185652.7353.28.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpWG-Pd-qE05B8ETwBMnVGuxVCES-zrL=wyxKAfZwnbwyQ@mail.gmail.com>
	<CAEA6p_CfDYYLf-s0pUy7VNFH+46PDZSXNzUExXRAM_xv2w8tcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:35974 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbcCRSKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 14:10:05 -0400
Received: by mail-yw0-f169.google.com with SMTP id g3so149024627ywa.3
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 11:10:04 -0700 (PDT)
In-Reply-To: <CAEA6p_CfDYYLf-s0pUy7VNFH+46PDZSXNzUExXRAM_xv2w8tcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 10:45 AM, Wei Wang <weiwan@google.com> wrote:
> Thanks all for the comments.
>
> Cong, you are right that for ipv6, the code does not take care of updating
> sk_dst_cache entry like Ipv4. And this patch is updating the entry by
> calling ip6_dst_store() to achieve similar functionality as Ipv4.

My question is why not updating ip6_sk_update_pmtu() to sync with ipv4?
