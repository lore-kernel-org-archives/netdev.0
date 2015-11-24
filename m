From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH v2 1/6] ipaddress: make flush command more
 error-tolerant
Date: Mon, 23 Nov 2015 16:31:15 -0800
Message-ID: <20151123163115.5f8be482@xeon-e3>
References: <1447010471-559-1-git-send-email-phil@nwl.cc>
	<1447014141-3565-1-git-send-email-phil@nwl.cc>
	<1447014141-3565-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:39701 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751843AbbKXAbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 19:31:11 -0500
In-Reply-To: <1447014141-3565-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  8 Nov 2015 21:22:16 +0100
Phil Sutter <phil@nwl.cc> wrote:

> The core issue here is that with promote_secondaries sysctl setting
> being turned off, removing the primary address implicitly removes all
> secondaries as well. Iproute is aware of this and therefore tries to
> remove all secondary addresses first to circumvent errors due to
> removing non-existent addresses. But this works only if not too many IP
> addresses are assigned to an interface, otherwise the RTM_GETADDR
> response is split up into multiple buffers. In my test-case, flushing
> more than 42 IPv4 addresses was sufficient to trigger an error:
> 
> Failed to send flush request: Cannot assign requested address
> 
> This patch fixes the issue by simply ignoring EADDRNOTAVAIL when
> flushing.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Patch does not apply to current tree. I applied an earlier patch from Neil Horman
and this supersedes this.

Please redo the patch series.
