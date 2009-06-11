From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 5/6] rio: warn_unused_result warnings fix
Date: Wed, 10 Jun 2009 23:34:03 -0500
Message-ID: <49B70D0E-63FD-45B1-AA86-6EF330D11D06@kernel.crashing.org>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com> <1242117363-14949-2-git-send-email-leoli@freescale.com> <1242117363-14949-3-git-send-email-leoli@freescale.com> <1242117363-14949-4-git-send-email-leoli@freescale.com> <1242117363-14949-5-git-send-email-leoli@freescale.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	mporter@kernel.crashing.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55547 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989AbZFKFCC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 01:02:02 -0400
In-Reply-To: <1242117363-14949-5-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 12, 2009, at 3:36 AM, Li Yang wrote:

> Adding failure path for the following two cases.
>
> warning: ignoring return value of 'device_add', declared with  
> attribute warn_unused_result
> warning: ignoring return value of 'sysfs_create_bin_file', declared  
> with attribute warn_unused_result
>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
> drivers/rapidio/rio-scan.c  |   44 +++++++++++++++++++++++++ 
> +----------------
> drivers/rapidio/rio-sysfs.c |    6 +++-
> 2 files changed, 31 insertions(+), 19 deletions(-)

applied w/fixup based on Andrew's comments.

- k
