From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: correctly handling failed allocation in fsm
Date: Mon, 04 Jan 2016 17:16:23 -0500 (EST)
Message-ID: <20160104.171623.390136612811420223.davem@davemloft.net>
References: <1451425293-30262-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451425293-30262-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Tue, 29 Dec 2015 16:41:33 -0500

> Since kzalloc can be failed in memory pressure,
> NULL dereference can be happened.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Similarly to your other mISDN patch you must propagate and handle
errors properly.
