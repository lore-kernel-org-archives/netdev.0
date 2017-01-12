From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] [v2] net: qcom/emac: grab a reference to the phydev on
 ACPI systems
Date: Thu, 12 Jan 2017 10:07:53 +0100
Message-ID: <20170112090753.GD7420@localhost>
References: <1484174751-19036-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        johan@kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36823 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751259AbdALJH6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 04:07:58 -0500
Received: by mail-lf0-f65.google.com with SMTP id h65so1122055lfi.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 01:07:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484174751-19036-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 04:45:51PM -0600, Timur Tabi wrote:
> Commit 6ffe1c4cd0a7 ("net: qcom/emac: fix of_node and phydev leaks")
> fixed the problem with reference leaks on phydev, but the fix is
> device-tree specific.  When the driver unloads, the reference is
> dropped only on DT systems.
> 
> Instead, it's cleaner if up grab an reference on ACPI systems.
> When the driver unloads, we can drop the reference without having
> to check whether we're on a DT system.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Reviewed-by: Johan Hovold <johan@kernel.org>
