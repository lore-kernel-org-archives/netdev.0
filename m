From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] [net] af_unix: return data from multiple SKBs
 on recv() with MSG_PEEK flag
Date: Thu, 24 Sep 2015 12:14:59 -0700 (PDT)
Message-ID: <20150924.121459.1016780653505420756.davem@davemloft.net>
References: <1442881622-11316-1-git-send-email-aconole@bytheb.org>
	<1442881622-11316-3-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbbIXTPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 15:15:00 -0400
In-Reply-To: <1442881622-11316-3-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>
Date: Mon, 21 Sep 2015 20:27:02 -0400

> +			goto unlock;

Sorry, I don't want to see goto's from one loop into a completely
different one.

The XXX comment is probably not appropriate either.
