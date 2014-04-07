From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netdev: remove potentially harmful checks
Date: Mon, 07 Apr 2014 15:52:46 -0400 (EDT)
Message-ID: <20140407.155246.1115800673081965447.davem@davemloft.net>
References: <1396862712-5225-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com, edumazet@google.com,
	nicolas.dichtel@6wind.com, jiri@resnulli.us,
	stephen@networkplumber.org, hkchu@google.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755308AbaDGTwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 15:52:49 -0400
In-Reply-To: <1396862712-5225-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon,  7 Apr 2014 11:25:12 +0200

> Currently we're checking a variable for != NULL after actually
> dereferencing it, in netdev_lower_get_next_private*().
> 
> It's counter-intuitive at best, and can lead to faulty usage (as it implies
> that the variable can be NULL), so fix it by removing the useless checks.
> 
> Reported-by: Daniel Borkmann <dborkman@redhat.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: stephen hemminger <stephen@networkplumber.org>
> CC: Jerry Chu <hkchu@google.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
