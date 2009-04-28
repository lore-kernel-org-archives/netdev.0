From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] forcedeth: add clock gating feature
Date: Tue, 28 Apr 2009 12:06:21 +0300
Message-ID: <49F6C70D.5010105@teltonika.lt>
References: <49F5A5A7.4050609@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:38793 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752412AbZD1JG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 05:06:27 -0400
In-Reply-To: <49F5A5A7.4050609@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch adds support for clock gating the tx/rx engines which is
> available on certain chipsets.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 

Please inline patch. It is easier to write comments.

+		writel(powerstate,base + NvRegPowerState2);
                                 ^
                           put space here
