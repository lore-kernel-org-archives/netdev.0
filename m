From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sctp: align MTU to a word
Date: Fri, 18 Mar 2016 15:09:34 -0700
Message-ID: <1458338974.31963.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458337159-22792-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34897 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbcCRWJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 18:09:36 -0400
In-Reply-To: <1458337159-22792-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-18 at 18:39 -0300, Marcelo Ricardo Leitner wrote:

> -		transport->pathmtu = dst_mtu(transport->dst);
> +		transport->pathmtu = dst_mtu(transport->dst) & ~3;


Well, surely a helper doing this would be better than spreading & ~3 all
over the places ;)
