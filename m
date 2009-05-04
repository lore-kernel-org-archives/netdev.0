From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 04 May 2009 20:22:19 +0200
Message-ID: <49FF325B.4050802@gmail.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:35343 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbZEDSWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 14:22:30 -0400
Received: by bwz22 with SMTP id 22so629333bwz.37
        for <netdev@vger.kernel.org>; Mon, 04 May 2009 11:22:29 -0700 (PDT)
In-Reply-To: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote, On 05/04/2009 06:03 AM:

> This is an update of the receive packet steering patch (RPS) based on received
> comments (thanks for all the comments).  Improvements are:

...

> +/* Called from hardirq (IPI) context */
> +static void trigger_softirq(void *data)
> +{
> +	struct softnet_data *queue = data;
> +	__napi_schedule(&queue->backlog);
> +}


Isn't full napi_schedule() needed here?

Jarek P.
