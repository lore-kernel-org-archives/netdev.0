From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH 10/10] pxa: make littleton to use the new smc91x platform
 data
Date: Fri, 27 Jun 2008 14:18:00 +0800
Message-ID: <48648618.5060900@gmail.com>
References: <> <1214300867-15495-11-git-send-email-eric.y.miao@gmail.com> <4864816F.5070407@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Nicolas Pitre <nico@cam.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:35034 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbYF0GSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 02:18:12 -0400
Received: by rv-out-0506.google.com with SMTP id k40so406892rvb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 23:18:12 -0700 (PDT)
In-Reply-To: <4864816F.5070407@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Eric Miao wrote:
>> From: Eric Miao <eric.miao@marvell.com>
>>
>> Signed-off-by: Eric Miao <eric.miao@marvell.com>
>> ---
>>  arch/arm/mach-pxa/littleton.c |    9 +++++++++
>>  drivers/net/smc91x.h          |    3 ++-
>>  2 files changed, 11 insertions(+), 1 deletions(-)
> 
> The rest of the patches seem OK.
> 
> What do ARM people prefer -- should I ACK this series, and let it be
> merged via an ARM tree?
> 

Well, I guess there are still some smc91x patches around and I'm not
sure if they will go inside the next merge window. So ideally, it'll
be best for "smc91x: *" patches go through the net-2.6, and I can
manage the rest to go through Russell's tree.

If you are OK with this, I'll send the smc91x specific patches to
you, together with Nico's Ack and a minor modification suggestion.

And either way will work if you prefer this to go through Russell's
arm tree.

> The series is mainly platform-oriented rather than net-oriented.
> 
> 

Yes, indeed.

