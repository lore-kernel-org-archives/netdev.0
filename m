From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] vxlan: Use RCU apis to access sk_user_data.
Date: Tue, 24 Sep 2013 09:20:50 -0700
Message-ID: <20130924092050.2c80bc74@nehalam.linuxnetplumber.net>
References: <1380000501-13969-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:45265 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab3IXQUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:20:55 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so4799446pbc.29
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:20:55 -0700 (PDT)
In-Reply-To: <1380000501-13969-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Sep 2013 22:28:21 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

>  
> +#define sk_user_data_rcu(sk) ((*((void __rcu **)&(sk)->sk_user_data)))

I don't like the macro, is it just to keep sparse happy?
The name also implies that rcu_dereference() is built in.
