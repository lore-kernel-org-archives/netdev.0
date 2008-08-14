From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] uninline atl1e_setup_mac_ctrl()
Date: Thu, 14 Aug 2008 04:45:30 -0400
Message-ID: <48A3F0AA.3080806@pobox.com>
References: <20080808183334.GZ14495@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jie Yang <jie.yang@atheros.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758383AbYHNIp6@vger.kernel.org>
In-Reply-To: <20080808183334.GZ14495@cs181140183.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> There doesn't seem to be a compelling reason why atl1e_setup_mac_ctrl() 
> is marked as "inline":
> 
> It's not used in any place where speed would matter much, and as long as 
> it has only one caller non-ancient gcc versions anyway inline it 
> automatically.
> 
> This patch fixes the following compile error with gcc 3.4:
> 
> <--  snip  -->
> 
> ...
>   CC      drivers/net/atl1e/atl1e_main.o
> atl1e_main.c: In function `atl1e_check_link':
> atl1e_main.c:50: sorry, unimplemented: inlining failed in call to 
> atl1e_main.c:196: sorry, unimplemented: called from here
> make[4]: *** [drivers/net/atl1e/atl1e_main.o] Error 1
> 
> <--  snip  -->
> 
> Reported-by: Adrian Bunk <bunk@kernel.org>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

applied
