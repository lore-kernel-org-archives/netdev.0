From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: allow userspace to take control over
 carrier
Date: Wed, 06 Feb 2013 15:51:20 -0500 (EST)
Message-ID: <20130206.155120.2001370462442418769.davem@davemloft.net>
References: <1360092655-28223-1-git-send-email-fbl@redhat.com>
	<20130205211645.GA1560@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, netdev@vger.kernel.org, jpirko@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758625Ab3BFUvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:51:22 -0500
In-Reply-To: <20130205211645.GA1560@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 5 Feb 2013 22:16:45 +0100

> Tue, Feb 05, 2013 at 08:30:55PM CET, fbl@redhat.com wrote:
>>Some modes don't require any special carrier handling so
>>in these cases, the kernel can control the carrier as for
>>any other interface.  However, some other modes, e.g. lacp,
>>requires more than just that, so userspace needs to control
>>the carrier itself.
>>
>>The daemon today is ready to control it, but the kernel
>>still can change it based on events.
>>
>>This fix so that either kernel or userspace is controlling
>>the carrier.
>>
>>Signed-off-by: Flavio Leitner <fbl@redhat.com>
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
