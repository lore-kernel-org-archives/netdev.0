From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: allow resetting slave failure
 counters
Date: Wed, 1 Jun 2011 13:51:25 +0000 (UTC)
Message-ID: <is5g4s$1h6$1@dough.gmane.org>
References: <1306921249-3623-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:52852 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879Ab1FANvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 09:51:41 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QRlpj-0003Jt-32
	for netdev@vger.kernel.org; Wed, 01 Jun 2011 15:51:39 +0200
Received: from 222-151-096-013.jp.fiberbit.net ([222.151.96.13])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 15:51:39 +0200
Received: from xiyou.wangcong by 222-151-096-013.jp.fiberbit.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 15:51:39 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Jun 2011 11:40:49 +0200, Jiri Pirko wrote:

> This patch allows to reset failure counters for all enslaved devices.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  Documentation/networking/bonding.txt |    7 +++++++
>  drivers/net/bonding/bond_sysfs.c     |   27 +++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/networking/bonding.txt
> b/Documentation/networking/bonding.txt index 675612f..2f51d73 100644
> --- a/Documentation/networking/bonding.txt +++
> b/Documentation/networking/bonding.txt @@ -782,6 +782,13 @@ resend_igmp
>  
>  	This option was added for bonding version 3.7.0.
>  
> +reset_failure_counters
> +
> +	This write-only control file will zero failure counters for +	all
> slaves.  Note there is no appropriate module parameter for this 
> +	since
> it would not make much sense. +	Write any value to perform reset.
> +

Writing any value includes zero will work? I think only non-zero
number makes sense, if we write zero, nothing should happen.

Thanks.

