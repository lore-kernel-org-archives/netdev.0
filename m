From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] e1000: To filter the negative skb->len
Date: Mon, 12 May 2014 21:04:21 -0700
Message-ID: <1399953861.7973.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399951987-10434-1-git-send-email-xuyongjiande@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xuyongjiande@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399951987-10434-1-git-send-email-xuyongjiande@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-05-13 at 11:33 +0800, xuyongjiande@gmail.com wrote:
> From: Yongjian Xu <xuyongjiande@gmail.com>
> 
> skb->len is unsigned int, "skb->len <= 0" should be "(int)(skb->len) <= 0".

Why ?

Did you hit a case skb->len would be 0 or 'negative' ?

This test makes no sense, just remove it.
