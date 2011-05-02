From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] networking: inappropriate ioctl operation should
 return ENOTTY
Date: Mon, 02 May 2011 15:41:48 -0700 (PDT)
Message-ID: <20110502.154148.246516437.davem@davemloft.net>
References: <20110427130904.47331a9f@lxorguk.ukuu.org.uk>
	<1303977891-29280-1-git-send-email-lifongsun@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lifongsun@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303977891-29280-1-git-send-email-lifongsun@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lifeng Sun <lifongsun@gmail.com>
Date: Thu, 28 Apr 2011 16:04:51 +0800

> ioctl() calls against a socket with an inappropriate ioctl operation
> are incorrectly returning EINVAL rather than ENOTTY:
> 
>   [ENOTTY]
>       Inappropriate I/O control operation.
> 
> BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=33992
> 
> Signed-off-by: Lifeng Sun <lifongsun@gmail.com>

Applied, thanks.
