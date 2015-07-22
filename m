From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: Fix setting a flag in br_fill_ifvlaninfo_range().
Date: Tue, 21 Jul 2015 22:52:09 -0700
Message-ID: <55AF2F89.3060401@cumulusnetworks.com>
References: <1437541022-14250-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: Rami Rosen <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36627 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbbGVFwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:52:12 -0400
Received: by pachj5 with SMTP id hj5so132751158pac.3
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 22:52:11 -0700 (PDT)
In-Reply-To: <1437541022-14250-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/15, 9:57 PM, Rami Rosen wrote:
> This patch fixes setting of vinfo.flags in the br_fill_ifvlaninfo_range() method. The
> assignment of vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN has no effect and is
> unneeded, as vinfo.flags value is overriden by the  immediately following
> vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END assignement.
>
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks.
