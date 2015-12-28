From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: use GFP_USER for user-controlled kmalloc
Date: Mon, 28 Dec 2015 00:15:02 -0500 (EST)
Message-ID: <20151228.001502.759949840855732365.davem@davemloft.net>
References: <CACT4Y+Ztb5cw2SGqxHiOBq9FgDs3J12Wk9iG0NaNvdunM_ex-w@mail.gmail.com>
	<e03c1ba5fef1bc2572475d7796290ca8acb95794.1450895185.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, nhorman@tuxdriver.com, dvyukov@google.com,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com
To: marcelo.leitner@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e03c1ba5fef1bc2572475d7796290ca8acb95794.1450895185.git.marcelo.leitner@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 23 Dec 2015 16:28:40 -0200

> Commit cacc06215271 ("sctp: use GFP_USER for user-controlled kmalloc")
> missed two other spots.
> 
> For connectx, as it's more likely to be used by kernel users of the API,
> it detects if GFP_USER should be used or not.
> 
> Fixes: cacc06215271 ("sctp: use GFP_USER for user-controlled kmalloc")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
