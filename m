From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH] netpoll: fix the skb check in pkt_is_ns
Date: Sat, 22 Mar 2014 08:24:52 +0800
Message-ID: <CAJFZqHw0gWVkshzp+2RrLCNHuhd+kn+7mFU4-jNkwo47iVwZbg@mail.gmail.com>
References: <1395406437-19834-1-git-send-email-roy.qing.li@gmail.com>
	<CAHA+R7Mwa_De9_vY32LdqxPDQqUnd6vBXMxh1jA2+s1kWNuD6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Cong Wang <amwang@redhat.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:34227 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbaCVAYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 20:24:53 -0400
Received: by mail-qc0-f175.google.com with SMTP id e16so3604328qcx.6
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 17:24:52 -0700 (PDT)
In-Reply-To: <CAHA+R7Mwa_De9_vY32LdqxPDQqUnd6vBXMxh1jA2+s1kWNuD6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 22, 2014 at 12:47 AM, Cong Wang <cwang@twopensource.com> wrote:
> But this code was just removed by:
>
> commit 9c62a68d13119a1ca9718381d97b0cb415ff4e9d
> Author: Eric W. Biederman <ebiederm@xmission.com>
> Date:   Fri Mar 14 20:51:52 2014 -0700
>
>     netpoll: Remove dead packet receive code (CONFIG_NETPOLL_TRAP)
>
>
> Or your patch is for -net? But CONFIG_NETPOLL_TRAP doesn't
> have any in-tree users, so we probably don't care


Yes, for net;
This bug is so dazzle before 9c62a68d13119a1ca9718381d97b0cb415ff4e9d
is merged into net

-Roy
