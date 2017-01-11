From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vrf: do not allow table id 0
Date: Wed, 11 Jan 2017 10:04:58 -0500 (EST)
Message-ID: <20170111.100458.1322323080511918611.davem@davemloft.net>
References: <1484090545-16407-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frank.kellermann@atos.net
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751052AbdAKPFA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:05:00 -0500
In-Reply-To: <1484090545-16407-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 10 Jan 2017 15:22:25 -0800

> Frank reported that vrf devices can be created with a table id of 0.
> This breaks many of the run time table id checks and should not be
> allowed. Detect this condition at create time and fail with EINVAL.
> 
> Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
> Reported-by: Frank Kellermann <frank.kellermann@atos.net>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David.
