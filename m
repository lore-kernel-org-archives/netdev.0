From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 13/54] macb: Call dev_kfree_skb_any instead of kfree_skb.
Date: Tue, 25 Mar 2014 06:21:46 -0700
Message-ID: <1395753706.12610.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-13-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33691 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbaCYNVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:21:49 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so431662pdb.0
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:21:48 -0700 (PDT)
In-Reply-To: <1395727540-12148-13-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace kfree_skb with dev_kfree_skb_any in macb_start_xmit that can
> be called in hard irq and other contexts.
> 
> macb_start_xmit only frees skbs when dropping them so
> dev_kfree_skb_any is used.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
