From: Andrew Morton <akpm@osdl.org>
Subject: Re: [2.6.11-rc4-mm1 patch] fix buggy IEEE80211_CRYPT_* selects
Date: Wed, 2 Mar 2005 14:14:15 -0800
Message-ID: <20050302141415.517b6b08.akpm@osdl.org>
References: <20050223014233.6710fd73.akpm@osdl.org>
	<20050226113123.GJ3311@stusta.de>
	<42256078.1040002@pobox.com>
	<20050302140833.GD4608@stusta.de>
	<42261004.4000501@pobox.com>
	<20050302123829.51dbc44b.akpm@osdl.org>
	<42262B08.2040401@pobox.com>
	<20050302131817.2e61805f.akpm@osdl.org>
	<20050302215607.GF4608@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050302215607.GF4608@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:
>
> > Would be better to just do:
> > 
> > config CRYPTO_AES
> > 	select CRYPTO_AES_586 if (X86 && !X86_64)
> > 	select CRYPTO_AES_OTHER if !(X86 && !X86_64)
> > 
> > and hide CRYPTO_AES_586 and CRYPTO_AES_OTHER from the outside world.
> 
> 
>   http://www.ussg.iu.edu/hypermail/linux/kernel/0502.3/0518.html

Please resubmit.
