From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 4/4] tc: Allow to easy change network namespace
Date: Sun, 14 Dec 2014 10:36:30 +0100
Message-ID: <20141214093630.GD2380@nanopsycho.orion>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
 <1418493334-23142-5-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:42963 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbaLNJgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 04:36:32 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so7998480wib.3
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 01:36:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1418493334-23142-5-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 13, 2014 at 06:55:34PM CET, vadim4j@gmail.com wrote:
>From: Vadim Kochan <vadim4j@gmail.com>
>
>Added new '-netns' option to simplify executing following cmd:
>
>    ip netns exec NETNS tc OPTIONS COMMAND OBJECT
>
>    to
>
>    tc -n[etns] NETNS OPTIONS COMMAND OBJECT
>
>e.g.:
>
>    tc -net vnet0 qdisc
>
>Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
