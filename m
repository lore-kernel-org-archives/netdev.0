From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ipv4: Simplify rt_fill_info
Date: Fri, 06 Jan 2017 15:57:20 -0500 (EST)
Message-ID: <20170106.155720.1929007635471620261.davem@davemloft.net>
References: <1483673566-14311-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41090 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939063AbdAFU51 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:57:27 -0500
In-Reply-To: <1483673566-14311-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  5 Jan 2017 19:32:46 -0800

> rt_fill_info has only 1 caller and both of the last 2 args -- nowait
> and flags -- are hardcoded to 0. Given that remove them as input arguments
> and simplify rt_fill_info accordingly.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
