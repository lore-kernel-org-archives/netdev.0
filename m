From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V4] tc: flower: Refactor matching flags to be
 more user friendly
Date: Thu, 19 Jan 2017 15:22:18 +0100
Message-ID: <20170119152218.61aa2fc4@griffin>
References: <1484835468-46051-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752856AbdASOW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 09:22:28 -0500
In-Reply-To: <1484835468-46051-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 16:17:48 +0200, Paul Blakey wrote:
> +	while (token) {
> +		if (!strncmp(token, "no", 2)) {
> +			no = true;
> +			token = strchr(token, '_') + 1;

This seems to still assume that "no" is followed by an underscore.
What about a simple token += 2?

 Jiri
