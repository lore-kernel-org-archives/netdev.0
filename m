From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: add debugfs support to dump internal
 tables
Date: Thu, 13 Aug 2015 21:29:57 -0700 (PDT)
Message-ID: <20150813.212957.728663371213139326.davem@davemloft.net>
References: <1439480116-41701-1-git-send-email-sfeldma@gmail.com>
	<20150813084639.2571eef0@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbbHNE36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 00:29:58 -0400
In-Reply-To: <20150813084639.2571eef0@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 13 Aug 2015 08:46:39 -0700

> Looks good.
> A couple caveats about debugfs.
> 1) Don't use it for API's not available elsewhere. You don't want it to become
>    a stable API which other tools get tied too.
> 2) Best to make it an optional config option (dependent on DEBUGFS)
>    that way it is possible to have rocker support w/o having DEBUGF configured.

Agreed, especially about making it optional and depend upon DEBUGFS.
