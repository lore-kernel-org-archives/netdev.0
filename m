From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] drivers/ptp: Fix kernel memory disclosure
Date: Wed, 12 Oct 2016 11:06:14 +0200
Message-ID: <20161012090614.GB3191@netboy>
References: <1476190967-38256-1-git-send-email-vlad@tsyrklevich.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35671 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932214AbcJLJGT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 05:06:19 -0400
Received: by mail-wm0-f65.google.com with SMTP id 123so1371418wmb.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 02:06:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1476190967-38256-1-git-send-email-vlad@tsyrklevich.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2016 at 03:02:47PM +0200, Vlad Tsyrklevich wrote:
> The reserved field precise_offset->rsv is not cleared before being
> copied to user space, leaking kernel stack memory. Clear the struct
> before it's copied.

Acked-by: Richard Cochran <richardcochran@gmail.com>
