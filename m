From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Wed, 21 Oct 2009 05:40:10 -0400
Message-ID: <4ADED6FA.2030502@gmail.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-9-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:40859 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbZJUJkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 05:40:09 -0400
Received: by ywh40 with SMTP id 40so4320243ywh.33
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 02:40:13 -0700 (PDT)
In-Reply-To: <1256115421-12714-9-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef wrote:
> +What:	sysctl_tcp_sack, sysctl_tcp_timestamps, sysctl_tcp_window_scaling,
> +	sysctl_tcp_dsack

Opposed to removing, as this is a common configuration for *BSD.  It helps
operators to have similar utility across systems.

net.inet.tcp.sack.enable

net.inet.tcp.timestamps

net.inet.tcp.win_scale

Support removing sysctl_tcp_dsack, as this appears to be Linux-only.
