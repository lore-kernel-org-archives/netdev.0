From: Jeremy Harris <jgh@redhat.com>
Subject: Re: [PATCH v2 1/1] net sysfs: Print link speed as signed integer
Date: Tue, 29 Sep 2015 16:13:46 +0100
Message-ID: <560AAAAA.1020605@redhat.com>
References: <1443445533-14474-1-git-send-email-alexander.stein@systec-electronic.com>
Reply-To: jgh@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933384AbbI2PNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 11:13:49 -0400
In-Reply-To: <1443445533-14474-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/09/15 14:05, Alexander Stein wrote:
> Otherwise 4294967295 (MBit/s) (-1) will be printed when there is no link.
> Documentation/ABI/testing/sysfs-class-net does not state if this shall be
> signed or unsigned.
> Also remove the now unused variable fmt_udec.
[...]
> -			ret = sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
> +			ret = sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));

If we print anything numeric, why is zero not appropriate
(which would still be unsigned)?
-- 
Cheers,
     Jeremy
