From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] team: update master carrier state
Date: Sun, 30 Dec 2012 22:47:23 +0100
Message-ID: <20121230214723.GD1575@minipsycho.orion>
References: <1356892049-14667-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:42755 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755049Ab2L3Vr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 16:47:27 -0500
Received: by mail-ea0-f173.google.com with SMTP id i13so4862100eaa.4
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 13:47:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1356892049-14667-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 30, 2012 at 07:27:29PM CET, fbl@redhat.com wrote:
>Update master's carrier state when there is any
>change with its ports.


This patch looks good to me. Just one nitpick I spotted....

>+	bool team_linkup;
>+
>+	team_linkup = false;


This can be squashed together.
