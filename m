From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 5/5] sock_diag: notify when filter change
Date: Wed, 24 Apr 2013 08:05:15 +0000 (UTC)
Message-ID: <kl83nr$8t3$1@ger.gmane.org>
References: <1366727277-19522-1-git-send-email-nicolas.dichtel@6wind.com>
 <1366727277-19522-6-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40230 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756813Ab3DXIFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 04:05:38 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UUuhm-0006EU-Ti
	for netdev@vger.kernel.org; Wed, 24 Apr 2013 10:05:30 +0200
Received: from 60.160.82.239 ([60.160.82.239])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 10:05:30 +0200
Received: from xiyou.wangcong by 60.160.82.239 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 10:05:30 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Apr 2013 at 14:27 GMT, Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> @@ -773,6 +775,7 @@ int sk_detach_filter(struct sock *sk)
>  		RCU_INIT_POINTER(sk->sk_filter, NULL);
>  		sk_filter_uncharge(sk, filter);
>  		ret = 0;
> +		sock_diag_notify(sk, 1);

Should be sock_diag_notify(sk, 0)?

BTW, use 'true' and 'false' instead of '1' and '0'.
