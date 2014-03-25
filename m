From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 36/54] forcedeth: Call dev_kfree_skb_any instead of
 kfree_skb.
Date: Tue, 25 Mar 2014 09:27:14 -0700
Message-ID: <1395764834.12610.158.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-36-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:43238 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbaCYQ1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 12:27:18 -0400
Received: by mail-qc0-f173.google.com with SMTP id r5so900155qcx.32
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 09:27:18 -0700 (PDT)
In-Reply-To: <1395727540-12148-36-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace kfree_skb with dev_kfree_skb_any in functions that can
> be called in hard irq and other contexts.
> 
> Every location changes is a drop making dev_kfree_skby_any appropriate.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
