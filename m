From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: fix warnings due to mismatched prototypes
Date: Wed, 02 Nov 2011 16:36:58 -0400 (EDT)
Message-ID: <20111102.163658.136546552375950246.davem@davemloft.net>
References: <1320266081-1387-1-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, loke.chetan@gmail.com
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab1KBUhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 16:37:03 -0400
In-Reply-To: <1320266081-1387-1-git-send-email-olof@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olof Johansson <olof@lixom.net>
Date: Wed,  2 Nov 2011 13:34:41 -0700

> Dave, let me know if you prefer to shuffle code around and move the
> inline helpers to the top instead -- I went with the smaller change by
> default.

Inline shouldn't be used at all, let the compiler decide.
