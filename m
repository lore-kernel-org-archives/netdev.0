From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v5 4/9] bgmac: simplify rx DMA error handling
Date: Mon, 13 Apr 2015 21:47:40 +0200
Message-ID: <552C1D5C.5090108@openwrt.org>
References: <1428946067-75650-1-git-send-email-nbd@openwrt.org> <1428946067-75650-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:53963 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346AbbDMTrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:47:45 -0400
In-Reply-To: <1428946067-75650-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-13 19:27, Felix Fietkau wrote:
> Unmap the DMA buffer before checking it. If an error occurs, free the
> buffer and allocate a new one. If allocation or mapping fails, retry as
> long as there is NAPI poll budget left (count every attempt instead of
> every frame).
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Sorry, have to send v6. There are some more issues in this patch
regarding the use of kfree().

- Felix
