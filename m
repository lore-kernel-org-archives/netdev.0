From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute] vxlan: Add support for remote checksum offload
Date: Sun, 29 Nov 2015 11:54:21 -0800
Message-ID: <20151129115421.43b196c5@xeon-e3>
References: <1448648623-3336620-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:3246 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752369AbbK2TyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 14:54:17 -0500
In-Reply-To: <1448648623-3336620-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Nov 2015 10:23:43 -0800
Tom Herbert <tom@herbertland.com> wrote:

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
> Testing:
> 
> Ran single netperf over mlnx4 to illustrate the effest:
> 
> - Without RCO (UDP csum set to zero)
>   4335.99 Mbps
> - With RCO enabled
>   7661.81 Mbps
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, thanks
