From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tipc: do not use tasklet_disable before
 tasklet_kill
Date: Sat, 03 Nov 2012 15:15:56 -0400 (EDT)
Message-ID: <20121103.151556.899752323466185527.davem@davemloft.net>
References: <1351670761-26749-1-git-send-email-xtfeng@gmail.com>
	<1351670761-26749-3-git-send-email-xtfeng@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dannyfeng@tencent.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: xtfeng@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351670761-26749-3-git-send-email-xtfeng@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiaotian Feng <xtfeng@gmail.com>
Date: Wed, 31 Oct 2012 16:06:01 +0800

> If tasklet_disable() is called before related tasklet handled,
> tasklet_kill will never be finished. tasklet_kill is enough.
> 
> Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>

Applied.
