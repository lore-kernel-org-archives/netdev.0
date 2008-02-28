From: "Gordon Farquharson" <gordonfarquharson@gmail.com>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Thu, 28 Feb 2008 14:21:21 -0700
Message-ID: <97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com>
References: <20080228014125.GI3078@tuxdriver.com>
	 <20080227.235110.242439399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.249]:28945 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbYB1VVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:21:22 -0500
Received: by hs-out-0708.google.com with SMTP id 54so3580951hsz.5
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 13:21:21 -0800 (PST)
In-Reply-To: <20080227.235110.242439399.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

On Thu, Feb 28, 2008 at 12:51 AM, David Miller <davem@davemloft.net> wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
>  Date: Wed, 27 Feb 2008 20:41:25 -0500
>
>
>  > Gordon Farquharson (1):
>  >       Fix b43 driver build for arm
>
>  Please revert this change and resend your pull request.
>
>  If file2alias doesn't work properly in a cross build environment, we
>  don't fix it by crapping up mod_devalias.h with these silly align
>  attribute annotations.

This was extensively discussed on LKML [1, 2] and the patch has been
merged into Andrew Morton's -mm tree. It is understood that this is
not the Right Way to fix to problem, hence the big fat comment in the
code. It would be great if you could reconsider your decision.

Thanks.

Gordon

[1] http://groups.google.com/group/linux.kernel/browse_thread/thread/0013ccdcfce3feaa/608657870eb62a12?#608657870eb62a12
[2] http://groups.google.com/group/linux.kernel/browse_thread/thread/13ccdcfce3feaa/a37a5fcbb6431eb0?lnk=gst&q=Fix+b43+driver+build+for+arm#a37a5fcbb6431eb0

-- 
Gordon Farquharson
GnuPG Key ID: 32D6D676
