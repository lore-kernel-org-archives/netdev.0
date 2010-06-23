From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: add dependency on fw class module
Date: Wed, 23 Jun 2010 12:19:01 +0100
Message-ID: <1277291941.26161.9.camel@localhost>
References: <1277276075-29322-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43613 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab0FWLTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 07:19:09 -0400
In-Reply-To: <1277276075-29322-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-22 at 23:54 -0700, Amit Kumar Salecha wrote:
> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> 
> netxen_nic and qlcnic driver depends on firmware_class module.
[...]

By the way, I noticed that these drivers are very similar, and it looks
like qlcnic has code for a bunch of NetXen boards even though it doesn't
include their device IDs in its device ID table.  Have you considered
merging the two?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

