From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] defxx: fix build warning
Date: Mon, 25 Jan 2016 10:52:36 -0800 (PST)
Message-ID: <20160125.105236.867468921843364464.davem@davemloft.net>
References: <1453707320-30556-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: macro@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453707320-30556-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Mon, 25 Jan 2016 13:05:20 +0530

> We are getting many build warnings about:
> 'bar_start' may be used uninitialized
> and
> 'bar_len' may be used uninitialized
> 
> They are not actually uninitialized as dfx_get_bars() will initialize
> them properly. But still lets have them initialized just to satisfy the
> compiler (gcc 4.8.2).
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Applied.
