From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: use setup_timer
Date: Fri, 24 Mar 2017 12:35:58 -0700 (PDT)
Message-ID: <20170324.123558.57462084179264116.davem@davemloft.net>
References: <83245247f4fd11e0d1d3f3d948595dc26465d05e.1490262844.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, mac@melware.de, arnd@arndb.de,
        akpm@linux-foundation.org, gabrielcsmo@gmail.com,
        peter@hurleysoftware.com, gregkh@linuxfoundation.org,
        mingo@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <83245247f4fd11e0d1d3f3d948595dc26465d05e.1490262844.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Thu, 23 Mar 2017 21:15:57 +0800

> Use setup_timer() instead of init_timer() to simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied, thanks.

It would be really nice to get rid of all of the (void *) casts these
calls do.  In particular this turns off type checking for the timer
method, which is really rediculous and dangerous.
