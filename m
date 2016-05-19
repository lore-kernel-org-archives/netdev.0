From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] net: suppress warnings on dev_alloc_skb
Date: Thu, 19 May 2016 08:48:56 -0700
Message-ID: <1463672936.18194.195.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
	 <1463671854-26829-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33344 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228AbcESPs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 11:48:59 -0400
Received: by mail-pa0-f66.google.com with SMTP id gh9so8270785pac.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 08:48:58 -0700 (PDT)
In-Reply-To: <1463671854-26829-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 11:30 -0400, Neil Horman wrote:
> Noticed an allocation failure in a network driver the other day on a 32 bit
> system:

Presumably driver could fall back to HIGH memory allocation for the page
frag.
