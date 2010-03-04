From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v4] ethtool: Add direct access to ops->get_sset_count
Date: Thu, 04 Mar 2010 08:23:05 -0500
Message-ID: <4B8FB439.8050901@garzik.org>
References: <20100304085054.4471.44679.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:55093 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777Ab0CDNXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 08:23:11 -0500
Received: by vws9 with SMTP id 9so1189841vws.19
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 05:23:10 -0800 (PST)
In-Reply-To: <20100304085054.4471.44679.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2010 03:51 AM, Jeff Kirsher wrote:
> From: Jeff Garzik<jgarzik@redhat.com>
>
> This patch is an alternative approach for accessing string
> counts, vs. the drvinfo indirect approach.  This way the drvinfo
> space doesn't run out, and we don't break ABI later.
>
> Signed-off-by: Jeff Garzik<jgarzik@redhat.com>
> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>
>   include/linux/ethtool.h |   17 +++++++++--
>   net/core/ethtool.c      |   72 +++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 86 insertions(+), 3 deletions(-)

Both patches look good to me.  There is a cosmetic issue of needing to 
sync up userspace and kernel ethtool.h WRT whitespace and deleted 
constants, but I can do that after DaveM applies this patch.

Waiting for upstream application, or other objections...


