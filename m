From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v4 02/10] net: Add queue state xoff flag for stack
Date: Tue, 29 Nov 2011 08:12:51 -0500
Message-ID: <1322572371.2090.1.camel@mojatatu>
References: <alpine.DEB.2.00.1111281816540.24308@pokey.mtv.corp.google.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:65182 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754920Ab1K2NM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 08:12:58 -0500
Received: by yenl6 with SMTP id l6so4027231yen.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 05:12:58 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111281816540.24308@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 18:32 -0800, Tom Herbert wrote:
>  
>  enum netdev_queue_state_t {
> -       __QUEUE_STATE_XOFF,
> +       __QUEUE_STATE_DRV_XOFF,
> +       __QUEUE_STATE_STACK_XOFF,
>         __QUEUE_STATE_FROZEN,

QUEUE_STATE_DRV_XOFF seems to be a rename of __QUEUE_STATE_XOFF
no issues there.
Is inserting __QUEUE_STATE_STACK_XOFF going to cause any issues?
Typically, you should insert new things at the end.

cheers,
jamal
