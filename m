From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] netdev: Fix compile error in Octeon MGMT driver.
Date: Thu, 5 Nov 2009 21:45:47 +0100
Message-ID: <20091105204547.GA10292@linux-mips.org>
References: <1257449912-27978-1-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:52705 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758428AbZKEUoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 15:44:14 -0500
Received: from localhost.localdomain ([127.0.0.1]:34544 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-FAIL) by ftp.linux-mips.org with ESMTP
	id S1493078AbZKEUoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 21:44:19 +0100
Content-Disposition: inline
In-Reply-To: <1257449912-27978-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 05, 2009 at 11:38:32AM -0800, David Daney wrote:

> Explicitly include linux/capability.h.  Under some configurations it
> wasn't being indirectly included.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
> ---
> This fixes a minor problem for the (already approved) patches that
> Ralf has queued for 2.6.33.  It should probably be added to Ralf's
> queue.
> 
>  drivers/net/octeon/octeon_mgmt.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

Folded into the existing patch.  Thanks!

  Ralf
