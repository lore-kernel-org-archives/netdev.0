From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] v2: Driver: hv: netvsc: call dump_rndis_message()
 only in netvsc debug mode
Date: Tue, 21 Apr 2015 17:45:40 -0400 (EDT)
Message-ID: <20150421.174540.2189432113402169667.davem@davemloft.net>
References: <1429652635-22698-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sixiao@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429652635-22698-1-git-send-email-sixiao@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sixiao@microsoft.com
Date: Tue, 21 Apr 2015 14:43:55 -0700

> From: Simon Xiao <sixiao@microsoft.com>
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>

This commit message is lacking an explanation why you want to do
what you are doing.

Also, we have an existing mechanism to control network device driver
debug logging output, please use it rather than invent your own
facility.
