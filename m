From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] net/core: some functions' definition order adjustment
 for readability
Date: Wed, 18 Jul 2007 14:39:27 +0200
Message-ID: <469E09FF.5050203@trash.net>
References: <20070718.030306.50591269.davem@davemloft.net> <1184758229305-git-send-email-crquan@gmail.com> <11847582511783-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	linux-kernel@vger.kernel.org
To: Denis Cheng <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37640 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbXGRMjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 08:39:55 -0400
In-Reply-To: <11847582511783-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This could be done in the patch moving it .. anyways,


Denis Cheng wrote:
> +#ifdef CONFIG_PROC_FS
> +static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)


If you're interested in doing more work, it would be nice to
generalize the seq-file functions for unicast and multicast
address lists and add /proc/net/dev_unicast or something like
that.

OTOH we could also export this using rtnetlink. The main reason
why I didn't do that is that it can only be read, not changed,
but this is also true for statistics etc. Any opinions on this?

