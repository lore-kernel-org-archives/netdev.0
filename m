From: Adrian Chadd <adrian@freebsd.org>
Subject: Re: [PATCH wireless-next 2/3] ath5k: Introduce _ath5k_printk to
 reduce code/text
Date: Sun, 18 Mar 2012 21:36:49 -0700
Message-ID: <CAJ-Vmo=ceSV38vQGfs8cKJScWjYF4kbQdK3+JJvQLCmnURaEwA@mail.gmail.com>
References: <cover.1332116921.git.joe@perches.com>
	<b157e2d1a746733d1814b9726f326d52d36da2fc.1332116921.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b157e2d1a746733d1814b9726f326d52d36da2fc.1332116921.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

So the reason this is a macro in the FreeBSD HAL is so that the args
aren't evaluated unless the level (or debug bitmap in my case) fires
off.

Otherwise compiling in debugging will cause a _lot_ of spurious
register reads to occur that are then tossed. This was one of the big
reasons for instability and slow performance when AH_DEBUG was
enabled.



Adrian
