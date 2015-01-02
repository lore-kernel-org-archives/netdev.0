From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qmi_wwan: Set random MAC on devices with buggy fw
Date: Fri, 02 Jan 2015 16:42:07 -0500 (EST)
Message-ID: <20150102.164207.1916156409658764329.davem@davemloft.net>
References: <1420212105-20278-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, bjorn@mork.no
To: kristian.evensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbbABVmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:42:09 -0500
In-Reply-To: <1420212105-20278-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>
Date: Fri,  2 Jan 2015 16:21:45 +0100

> From: Kristian Evensen <kristian.evensen@gmail.com>
> 
> Some buggy firmwares export an incorrect MAC address (00:a0:c6:00:00:00). This
> makes for example checking devices for random MAC addresses tricky, and you
> might end up with multiple network interfaces with the same address.
> 
> This patch tries to fix, or at least improve, the situation by setting the MAC
> address of devices with this firmware bug to a random address. I tested the
> patch with two devices that has this firmware bug (Huawei E398 and E392), and
> network traffic worked fine after changing the address.
> 
> Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>

Applied.
