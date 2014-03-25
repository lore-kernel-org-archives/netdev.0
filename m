From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 35/54] vxge: Call dev_kfree_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 09:26:27 -0700
Message-ID: <1395764787.12610.157.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-35-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:52826 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751AbaCYQ03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 12:26:29 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so650768pdj.20
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 09:26:28 -0700 (PDT)
In-Reply-To: <1395727540-12148-35-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in vxge_xmit that can
> be called in hard irq and other contexts.
> 
> vxge_xmit only calls dev_kfree_skb_any when errors result in dropping
> skbs.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
