From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] forcedeth: fix nic poll
Date: Wed, 28 Mar 2007 02:19:03 -0400
Message-ID: <460A08D7.8070403@pobox.com>
References: <4603B0C1.3050100@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42306 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbXC1GTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 02:19:14 -0400
In-Reply-To: <4603B0C1.3050100@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> The nic poll routine was missing the call to the optimized irq routine. 
> This patch adds the missing call for the optimized path.
> 
> See http://bugzilla.kernel.org/show_bug.cgi?id=7950 for more information.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

applied 1-2


