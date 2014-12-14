From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 2/4] ip: Allow to easy change network namespace
Date: Sun, 14 Dec 2014 10:36:02 +0100
Message-ID: <20141214093602.GB2380@nanopsycho.orion>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
 <1418493334-23142-3-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:46229 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbaLNJgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 04:36:05 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so6317167wiv.8
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 01:36:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1418493334-23142-3-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 13, 2014 at 06:55:32PM CET, vadim4j@gmail.com wrote:
>From: Vadim Kochan <vadim4j@gmail.com>
>
>Added new '-netns' option to simplify executing following cmd:
>
>    ip netns exec NETNS ip OPTIONS COMMAND OBJECT
>
>    to
>
>    ip -n[etns] NETNS OPTIONS COMMAND OBJECT
>
>e.g.:
>
>    ip -net vnet0 link add br0 type bridge
>    ip -n vnet0 link
>
>Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
