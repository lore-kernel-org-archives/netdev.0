From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 1/4] mips: Update some more defconfigs which were missing
 CONFIG_NET.
Date: Wed, 24 Sep 2014 13:40:07 -0700
Message-ID: <20140924204007.GC27927@roeck-us.net>
References: <20140924.144914.467369651395057588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:43654 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbaIXUkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:40:12 -0400
Received: by mail-pd0-f174.google.com with SMTP id g10so8772369pdj.33
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 13:40:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140924.144914.467369651395057588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 02:49:14PM -0400, David Miller wrote:
> 
> Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
> 'select'.")  removed what happened to be the only instance of 'select
> NET'. Defconfigs that were relying on the select now lack networking
> support.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  arch/mips/configs/nlm_xlp_defconfig | 1 +
>  arch/mips/configs/nlm_xlr_defconfig | 1 +

My list of affected configurations is much larger.

mips:gpr_defconfig
mips:ip27_defconfig
mips:jazz_defconfig
mips:loongson3_defconfig
mips:malta_defconfig
mips:malta_kvm_defconfig
mips:malta_kvm_guest_defconfig
mips:mtx1_defconfig
mips:nlm_xlp_defconfig
mips:nlm_xlr_defconfig
mips:rm200_defconfig

Guenter
