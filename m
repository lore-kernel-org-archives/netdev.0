From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH iproute2] ipnetns: fix ip batch mode when using 'netns
 exec'
Date: Wed, 28 Aug 2013 08:13:31 +0000 (UTC)
Message-ID: <kvkbf9$j48$2@ger.gmane.org>
References: <1377588334-13538-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59821 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702Ab3H1INz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 04:13:55 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VEasw-0001d8-Mk
	for netdev@vger.kernel.org; Wed, 28 Aug 2013 10:13:50 +0200
Received: from 36.58.190.45 ([36.58.190.45])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 10:13:50 +0200
Received: from xiyou.wangcong by 36.58.190.45 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 10:13:50 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Aug 2013 at 07:25 GMT, Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>  
> -			/* If child failed, propagate status */
> -			if (WIFEXITED(status))
> -				exit(WEXITSTATUS(status));
> +			if (WIFEXITED(status)) {
> +				/* ip must returns the status of the child,

s/returns/return/
