From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Checkpatch: coding style errors in Nvidia ethernet
 driver
Date: Fri, 10 Oct 2014 14:25:46 -0400 (EDT)
Message-ID: <20141010.142546.2200998192474741214.davem@davemloft.net>
References: <1412928102-1696-1-git-send-email-akshaysarode21@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.stultz@linaro.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: akshaysarode21@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412928102-1696-1-git-send-email-akshaysarode21@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Akshay Sarode <akshaysarode21@gmail.com>
Date: Fri, 10 Oct 2014 13:31:42 +0530

> ERROR: "foo* bar" should be "foo *bar"
> ERROR: do not initialise statics to 0 or NULL
> CHECK: spinlock_t definition without comment
> Signed-off-by: Akshay Sarode <akshaysarode21@gmail.com>

The Subject "Subsystem: " prefix is meant to refer to what area of
the kernel you are changing.

You aren't making changes to "Checkpatch: " so that isn't an
appropriate prefix.  Someone scanning the commit header lines
won't be able to tell what part of the kernel your change is
touching.

In this case you should use "nvidia: " as your subsystem
prefix.
