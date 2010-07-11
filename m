From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 5/5] cxgb4: exclude registers with read side
 effects from register dumps
Date: Sun, 11 Jul 2010 23:17:06 +0100
Message-ID: <1278886626.6139.87.camel@localhost>
References: <1278885679-3738-1-git-send-email-dm@chelsio.com>
	 <1278885679-3738-2-git-send-email-dm@chelsio.com>
	 <1278885679-3738-3-git-send-email-dm@chelsio.com>
	 <1278885679-3738-4-git-send-email-dm@chelsio.com>
	 <1278885679-3738-5-git-send-email-dm@chelsio.com>
	 <1278885679-3738-6-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12689 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab0GKWRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 18:17:11 -0400
In-Reply-To: <1278885679-3738-6-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-07-11 at 15:01 -0700, Dimitris Michailidis wrote:
> A few registers have side effects on reads, eg FIFO pointers that
> auto advance or mailboxes which change ownership when read.  They are
> unsafe to read so exclude them from ethtool register dumps.
[...]

If you change the set of registers in the dump, you need to increment
the version number.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

