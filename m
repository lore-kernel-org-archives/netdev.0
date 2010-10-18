From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net_sched: remove the unused parameter of
 qdisc_create_dflt()
Date: Mon, 18 Oct 2010 08:20:25 -0400
Message-ID: <1287404425.3664.186.camel@bigi>
References: <1287270248-13190-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, netem@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52018 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439Ab0JRMU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 08:20:28 -0400
Received: by gxk6 with SMTP id 6so305733gxk.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 05:20:28 -0700 (PDT)
In-Reply-To: <1287270248-13190-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-10-17 at 07:04 +0800, Changli Gao wrote:
> The first parameter dev isn't in use in qdisc_create_dflt().

And we can derive it from netdev_queue if ever needed in the future.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

