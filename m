From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] drivers: net: xgene: Fix backward compatibility
 of newer firmware with older kernel
Date: Wed, 04 Mar 2015 15:54:38 -0500 (EST)
Message-ID: <20150304.155438.1283662648499374073.davem@davemloft.net>
References: <1425411581-25463-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, mlangsdo@redhat.com,
	patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbbCDUyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:54:40 -0500
In-Reply-To: <1425411581-25463-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Tue,  3 Mar 2015 11:39:38 -0800

> Kernel 3.17 driver supports only RGMII ethernet interface.
> Since the Tianocore DT contains same compatibility string for RGMII,
> SGMII based 1G and XFI based 10G interfaces, crash happens when probe called
> on SGMII based 1G and XFI based 10G interface.
> 
> This patch fixes the backward compatibility of the older driver with the
> newer firmware by making the binding unique so that the older driver won't
> recognize the non-supported interfaces.
> 
> v2: Address comments from v1
> * updated cover letter subject line with net: xgene
> * Documentation: formatted compatible string values as list
> 
> v1:
> * Initial version

Series applied, thanks.
