From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip neigh: Add ifindex to request when filtering dumps
 by device
Date: Mon, 12 Oct 2015 09:44:12 -0700
Message-ID: <20151012094412.637f1f3a@urahara>
References: <1444238604-12632-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34411 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbbJLQoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:44:00 -0400
Received: by padhy16 with SMTP id hy16so158210987pad.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 09:43:59 -0700 (PDT)
In-Reply-To: <1444238604-12632-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Oct 2015 10:23:24 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Add ifindex to dump request when filtering by device. If the kernel
> supports it adding the index to the request limits the amount of data
> the kernel pushes to userpsace.
> 
> The feature exists in userspace already, so no need to warn the user
> if kernel side support does not exist. Using the kernel side filter
> makes the request more efficient.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied to net-next branch
