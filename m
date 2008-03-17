From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: limit tx to 16
Date: Mon, 17 Mar 2008 08:12:02 -0400
Message-ID: <47DE6012.3050301@pobox.com>
References: <47D592DD.4070300@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>,
	stable@kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52367 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928AbYCQMML (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:12:11 -0400
In-Reply-To: <47D592DD.4070300@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This is a critical patch which adds a workaround for a HW bug. The patch 
> will limit the number of outstanding tx packets to 16. Otherwise, the HW 
> could send out packets with bad checksums.
> 
> The driver will still setup the tx packets into the ring, however, will 
> only set the Valid bit on 16 packets at a time.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied


