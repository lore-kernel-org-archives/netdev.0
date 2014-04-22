From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] ipv6: support IFA_F_MANAGETEMPADDR for address
 deletion too
Date: Tue, 22 Apr 2014 08:00:44 +0200
Message-ID: <20140422060044.GA2863@minipsycho.orion>
References: <53542020.8070904@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heiner Kallweit <heiner.kallweit@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:59899 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbaDVGAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 02:00:47 -0400
Received: by mail-ee0-f47.google.com with SMTP id b15so4107361eek.6
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 23:00:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53542020.8070904@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Apr 20, 2014 at 09:29:36PM CEST, heiner.kallweit@web.de wrote:
>Userspace applications can use IFA_F_MANAGETEMPADDR with RTM_NEWADDR
>already to indicate that the kernel should take care of temporary
>address management.
>
>This patch adds related functionality to RTM_DELADDR. By setting
>IFA_F_MANAGETEMPADDR a userspace application can indicate that the kernel
>should delete all related temporary addresses as well.
>
>A corresponding patch for the "ip addr del" command has been applied to
>iproute2 already.
>
>Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
