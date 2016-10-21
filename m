From: Zach Brown <zach.brown@ni.com>
Subject: Pure polling mode for netdevices
Date: Fri, 21 Oct 2016 13:03:17 -0500
Message-ID: <20161021180316.GA305@zach-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0121.outbound.protection.outlook.com ([104.47.41.121]:34560
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932695AbcJUSDc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 14:03:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a way to get NAPI to poll all the time?
Or just any way to get netdevices to use only polling and no interrupts?

We have some rt targets where the jitter can be improved by disabling
interrupts and using just polling. In these cases we're okay with the
performance downsides that come with polling.

In particular we already have an implementation for the cadence macb driver
that does only polling mode and have verified that it improves the
jitter.

We're hoping for a more general existing solution or at the very least a
solution that would be accepted upstream. Any thoughts?
