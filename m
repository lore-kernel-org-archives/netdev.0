From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hamradio: baycom_ser_fdx: Replace timeval with
 timespec64
Date: Thu, 11 Feb 2016 09:55:34 -0500 (EST)
Message-ID: <20160211.095534.840091300723732679.davem@davemloft.net>
References: <20160210043854.GA29381@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: t.sailer@alumni.ethz.ch, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	y2038@lists.linaro.org
To: amitoj1606@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20160210043854.GA29381@amitoj-Inspiron-3542>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Wed, 10 Feb 2016 10:08:54 +0530

> 32 bit systems using 'struct timeval' will break in the year 2038, so
> we replace the code appropriately. However, this driver is not broken
> in 2038 since we are only using microseconds portion of the time.
> 
> This patch replaces 'struct timeval' with 'struct timespec64'. We only
> need to find elapsed microseconds rather than absolute time, so it's
> better to use monotonic time, so using ktime_get_ts64() makes the code
> more efficient and more robust against concurrent settimeofday()
> calls.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>

Applied.
