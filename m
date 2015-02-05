From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/4] vxlan: Add support for remote checksum
 offload
Date: Thu, 5 Feb 2015 10:54:09 -0800
Message-ID: <20150205105409.68ddcb96@urahara>
References: <1422550321-30901-1-git-send-email-therbert@google.com>
	<1422550321-30901-3-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36783 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbbBESyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:54:14 -0500
Received: by pdev10 with SMTP id v10so9406292pde.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:54:13 -0800 (PST)
In-Reply-To: <1422550321-30901-3-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Jan 2015 08:51:59 -0800
Tom Herbert <therbert@google.com> wrote:

> This patch adds support to remote checksum checksum offload
> to VXLAN. This patch adds remcsumtx and remcsumrx to ip vxlan
> configuration to enable remote checksum offload for transmit
> and receive on the VXLAN tunnel.
> 
> https://tools.ietf.org/html/draft-herbert-vxlan-rco-00
> 
> Example:
> 
> ip link add name vxlan0 type vxlan id 42 group 239.1.1.1 dev eth0 \
>     udpcsum remcsumtx remcsumrx
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Does not apply to current iproute2 net-next branch because
the vxlan group policy extensions was applied first.

Please fix conflicts and resubmit.
