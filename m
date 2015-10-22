From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4] bnxt_en: New Broadcom ethernet driver.
Date: Wed, 21 Oct 2015 17:31:53 -0700
Message-ID: <20151021173153.0aac826e@xeon-e3>
References: <1445413508-14932-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <prashant@broadcom.com>,
	<eddie.wai@broadcom.com>, <huangjw@broadcom.com>,
	<netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37111 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbbJVAbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 20:31:44 -0400
Received: by igbhv6 with SMTP id hv6so49814485igb.0
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 17:31:44 -0700 (PDT)
In-Reply-To: <1445413508-14932-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Oct 2015 03:45:08 -0400
Michael Chan <mchan@broadcom.com> wrote:

> +static inline void bnxt_enable_poll(struct bnxt_napi *bnapi)
> +{
> +#ifdef CONFIG_NET_RX_BUSY_POLL
> +	atomic_set(&bnapi->poll_state, BNXT_STATE_IDLE);
> +#endif
> +}

We need a better way to abstract this and get the #ifdef
clutter out of the network drivers.
