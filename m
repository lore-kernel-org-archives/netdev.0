From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH v4] ethtool: Correctly pull n-tuple string length
 for	get_rx_ntuple
Date: Tue, 30 Mar 2010 13:11:42 -0400
Message-ID: <4BB230CE.5090304@garzik.org>
References: <20100304085328.4510.9284.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:7420 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755287Ab0C3RLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 13:11:47 -0400
Received: by qw-out-2122.google.com with SMTP id 8so3820488qwh.37
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 10:11:45 -0700 (PDT)
In-Reply-To: <20100304085328.4510.9284.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2010 03:53 AM, Jeff Kirsher wrote:
> From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>
> This patch fixes inconsistencies with the kernel header files, while
> correctly gets the variable length string counts for the get_rx_ntuple
> return value.  It does this by using the new GSSET_INFO ioctl.
>
> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>
>   ethtool-copy.h |   14 ++++++++++++--
>   ethtool.c      |   19 ++++++++++++++++---
>   2 files changed, 28 insertions(+), 5 deletions(-)

applied


