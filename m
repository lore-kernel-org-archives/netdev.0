From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 2/2] tc: add support for BPF based actions
Date: Tue, 13 Jan 2015 17:19:17 -0800
Message-ID: <20150113171917.4d4cdafb@urahara>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
	<1420649244-9574-1-git-send-email-jiri@resnulli.us>
	<1420649244-9574-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:41138 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbbANBT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 20:19:27 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so7028669pad.9
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 17:19:27 -0800 (PST)
In-Reply-To: <1420649244-9574-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Jan 2015 17:47:24 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/tc_act/tc_bpf.h |  31 +++++++

The overall concept is fine, but the mechanics of file management
gets in the way.

All header files in the linux directory of iproute2 must come from sanitized
version of kernel headers that are in uapi/linux in the kernel source.

I take headers from 'make install_headers' and copy them over to keep
in sync. The headers for master branch are kept in sync with upstream
kernel (from Linus tree), and for net-next branch I derive them from Davem's
net-next tree.

If you want to use tc_bpf.h it has to be in upstream kernel first.

Sorry
