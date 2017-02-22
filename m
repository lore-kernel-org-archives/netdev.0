From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fjes: Move fjes driver info message into
 fjes_acpi_add()
Date: Wed, 22 Feb 2017 15:45:01 -0500 (EST)
Message-ID: <20170222.154501.1301489476392840185.davem@davemloft.net>
References: <210dfe59-18a0-4678-0a63-6751f21f0eb5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com
To: yasu.isimatu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934225AbdBVUpD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 15:45:03 -0500
In-Reply-To: <210dfe59-18a0-4678-0a63-6751f21f0eb5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Date: Wed, 22 Feb 2017 15:40:49 -0500

> To avoid the confusion, the patch moves the message into
> fjes_acpi_add() so that it is shows only when fjes_acpi_add()
> succeeded.

This change means it'll never be printed for platform driver matches,
which is even worse than what we have now.
