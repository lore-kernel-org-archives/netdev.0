From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] checkpatch: Add some --strict coding style checks
Date: Tue, 21 Feb 2012 13:09:17 -0800
Message-ID: <20120221130917.e41491d4.akpm@linux-foundation.org>
References: <20120221151435.GA19354@tuxdriver.com>
	<20120221.144417.1445117001833888214.davem@davemloft.net>
	<CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
	<20120221.154053.2103818562080068513.davem@davemloft.net>
	<1329857959.5143.11.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andy Whitcroft <apw@shadowen.org>,
	andrei.emeltchenko.news@gmail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329857959.5143.11.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Speaking of which, I just got this:

WARNING: %Ld/%Lu are not-standard C, use %lld/%llu
#142: FILE: fs/locks.c:2335:
+                       seq_printf(f, "Start-end:\t %Ld-EOF\n\n", fl->fl_start);

But %L saves a byte!  Why did we do this?  Don't you like puppies?
