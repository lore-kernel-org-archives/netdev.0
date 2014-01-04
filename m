From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: fix the wrong return value
Date: Fri, 03 Jan 2014 20:37:59 -0500 (EST)
Message-ID: <20140103.203759.2168117129392277198.davem@davemloft.net>
References: <1388719316-5702-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388719316-5702-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 3 Jan 2014 11:21:56 +0800

> The return value should be the boolean value, not the error code.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> Spotted-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, but I agree with others that it's more canonical to have the
function return either an error code, or zero for success, rather than
a boolean.
