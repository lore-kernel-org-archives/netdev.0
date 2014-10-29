From: Alexey Andriyanov <alan@al-an.info>
Subject: Re: [PATCH] ip6_tunnel: allow to change mode for the ip6tnl0
Date: Wed, 29 Oct 2014 10:46:56 +0300
Message-ID: <54509B70.1070708@al-an.info>
References: <1414563898-10347-1-git-send-email-alan@al-an.info> <1414565213.631.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward3l.mail.yandex.net ([84.201.143.136]:33172 "EHLO
	forward3l.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064AbaJ2HrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 03:47:00 -0400
In-Reply-To: <1414565213.631.77.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



29.10.2014 09:46, Eric Dumazet wrote:
> ...
>> The fallback device can not be hidden from the packet receiver
>> as a regular tunnel, but there is no need for synchronization
>> as long as we do single assignment.
> 
> This is not exact, I believe you need to add following changes :

Thank you, Eric, you're right, I missed that.
I'll repost the patch with your changes applied.

-- 
Best regards,
Alexey 
