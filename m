From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] wimax: fix kernel-doc for debufs_dentry member of struct
 wimax_dev [v2]
Date: Thu, 08 Jan 2009 21:36:40 -0800
Message-ID: <4966E268.20101@oracle.com>
References: <1231447827-7999-1-git-send-email-inaky@linux.intel.com> <1231448396-8582-1-git-send-email-inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:49414 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbZAIFgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 00:36:49 -0500
In-Reply-To: <1231448396-8582-1-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inaky Perez-Gonzalez wrote:
> Reported by Randy Dunlap from a warning in the v2.6.29 merge window
> tree as of 2009/1/8.
> 
> v2 fixes Randy Dunlap's email address.
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> Cc: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  include/net/wimax.h |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/wimax.h b/include/net/wimax.h
> index 1602614..073809c 100644
> --- a/include/net/wimax.h
> +++ b/include/net/wimax.h
> @@ -323,6 +323,9 @@ struct input_dev;
>   *
>   * @rf_hw: [private] State of the hardware radio switch (OFF/ON)
>   *
> + * @debufs_dentry: [private] Used to hook up a debugfs entry. This
> + *     shows up in the debugfs root as wimax:DEVICENAME.

Inaky, this was supposed to be @debugfs_dentry.  (typo)

> + *
>   * Description:
>   * This structure defines a common interface to access all WiMAX
>   * devices from different vendors and provides a common API as well as


-- 
~Randy
