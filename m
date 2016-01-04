From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: correctly handling failed allocation
Date: Mon, 04 Jan 2016 17:16:04 -0500 (EST)
Message-ID: <20160104.171604.1609827563372626339.davem@davemloft.net>
References: <1451425126-26958-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451425126-26958-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Tue, 29 Dec 2015 16:38:46 -0500

> Since kzalloc can be failed in memory pressure,
> NULL dereference might be happened.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Sorry, this is not a correct fix.

You need to propagate an error back to the callers, and
they must act upon that error.
