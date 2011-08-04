From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: restore wrap bit when performing underrun cleanup
Date: Thu, 04 Aug 2011 01:43:52 -0700 (PDT)
Message-ID: <20110804.014352.2136986087530764032.davem@davemloft.net>
References: <1312445507-31382-1-git-send-email-tord.andersson@endian.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tord.andersson@endian.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312445507-31382-1-git-send-email-tord.andersson@endian.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tord Andersson <tord.andersson@endian.se>
Date: Thu,  4 Aug 2011 10:11:47 +0200

> When TX underrun occurs, a cleanup is performed that marks all buffers as used. As a side effect it also clears the wrap bit in the last buffer. This patch will restore the wrap bit.
> 
> Signed-off-by: Tord Andersson <tord.andersson@endian.se>

Applied.
