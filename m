From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rose: correct integer overflow check
Date: Thu, 18 Feb 2016 15:33:29 -0500 (EST)
Message-ID: <20160218.153329.28621505199573578.davem@davemloft.net>
References: <1455740713-18262-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1455740713-18262-1-git-send-email-wuninsu@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Wed, 17 Feb 2016 15:25:13 -0500

> Since rose_ndevs is signed integer type,
> it can be overflowed when it is negative.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

That's not how the expression is evaluated.

Because of the types on the right hand side of the comparison
the expressions are all promoted to unsigned.

Did you look at the compiler's assembler output?  I did when
reviewing your patch.
