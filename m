From: Adrian Chadd <adrian@freebsd.org>
Subject: Re: [PATCH wireless-next 2/3] ath5k: Introduce _ath5k_printk to
 reduce code/text
Date: Mon, 19 Mar 2012 20:39:33 -0700
Message-ID: <CAJ-Vmom4n7Sk5P=HMb+Z-FNyfyk87Xbf5Q1kPA4i2eXwQ72kXQ@mail.gmail.com>
References: <cover.1332116921.git.joe@perches.com>
	<b157e2d1a746733d1814b9726f326d52d36da2fc.1332116921.git.joe@perches.com>
	<CAJ-Vmo=ceSV38vQGfs8cKJScWjYF4kbQdK3+JJvQLCmnURaEwA@mail.gmail.com>
	<1332134336.23125.60.camel@joe2Laptop>
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
In-Reply-To: <1332134336.23125.60.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18 March 2012 22:18, Joe Perches <joe@perches.com> wrote:

>> Otherwise compiling in debugging will cause a _lot_ of spurious
>> register reads to occur that are then tossed. This was one of the big
>> reasons for instability and slow performance when AH_DEBUG was
>> enabled.
>
> That doesn't make any sense in this case.
>
> It's either a call to printk or _ath5_printk
> but it's still a call to a function.

The FreeBSD HAL used to be like this. I changed it so it didn't
evaluate the arguments before it figured out whether or not to do the
(k)printf().

I'm just pointing it out as you're (currently) knee deep in the
debugging code and it may be useful for you to also think about
implementing.


adrian
