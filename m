From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] r6040: only disable RX interrupt if
 napi_schedule_prep is successful
Date: Fri, 15 Jul 2011 08:10:45 -0700 (PDT)
Message-ID: <20110715.081045.395109170877608048.davem@davemloft.net>
References: <1310729306-12190-1-git-send-email-Michael.Thalmeier@sigmatek.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, michael@thalmeier.at
To: Michael.Thalmeier@sigmatek.at
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1310729306-12190-1-git-send-email-Michael.Thalmeier@sigmatek.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Thalmeier <Michael.Thalmeier@sigmatek.at>
Date: Fri, 15 Jul 2011 13:28:26 +0200

> When receiving the first RX interrupt before the internal call
> to napi_schedule_prep is successful the RX interrupt gets disabled
> and is never enabled again as the poll function never gets executed.
> 
> Signed-off-by: Michael Thalmeier <Michael.Thalmeier@sigmatek.at>

Applied.
