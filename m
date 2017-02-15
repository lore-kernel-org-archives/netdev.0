From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: idt77252, use setup_timer and mod_timer
Date: Wed, 15 Feb 2017 13:25:07 -0500 (EST)
Message-ID: <20170215.132507.1641511278317210418.davem@davemloft.net>
References: <20170215155935.27606-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-kernel@vger.kernel.org,
        jan.koniarik@trustica.cz, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215155935.27606-1-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Wed, 15 Feb 2017 16:59:35 +0100

> From: Jan Koniarik <jan.koniarik@trustica.cz>
> 
> Stop accessing timer struct members directly and use setup_timer and
> mod_timer helpers intended for that use. It makes the code cleaner and
> will allow for easier change of the timer struct internals.
> 
> Signed-off-by: Jan Koniarik <jan.koniarik@trustica.cz>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Applied to net-next, thanks.
