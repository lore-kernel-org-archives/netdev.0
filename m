From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump
 internal tables
Date: Tue, 18 Aug 2015 11:42:02 -0700 (PDT)
Message-ID: <20150818.114202.1167464751085554567.davem@davemloft.net>
References: <1439850977-31079-1-git-send-email-sfeldma@gmail.com>
	<20150818055555.GA2200@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbbHRSmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 14:42:05 -0400
In-Reply-To: <20150818055555.GA2200@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 18 Aug 2015 07:55:55 +0200

> Tue, Aug 18, 2015 at 12:36:17AM CEST, sfeldma@gmail.com wrote:
>>+static int rocker_probe_debugfs_init(struct rocker *rocker)
>>+{
>>+	char dbg_dir_name[sizeof(rocker->hw.id) * 2 + 1];
>>+
>>+	sprintf(dbg_dir_name, "%*phN", (int)sizeof(rocker->hw.id),
>>+		&rocker->hw.id);
> 
> You can use PCI address here. Might be better.

This absolutely will not be unique in a multi-domain PCI configuration.

It is arguable whether that matters or not under qemu, but it's a bad
precedence to say that PCI addresses will be unique, they absolutely
are not unique between devices even of the same exact type.
