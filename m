From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 00/36] Convert DocBook documents to ReST
Date: Mon, 15 May 2017 11:11:41 -0600
Message-ID: <20170515111141.0fcd5ee6@lwn.net>
References: <cover.1494596071.git.mchehab@s-opensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, alsa-devel@alsa-project.org,
 Linux Doc Mailing List <linux-doc@vger.kernel.org>,
 Takashi Iwai <tiwai@suse.de>, Jan Kiszka <jan.kiszka@siemens.com>, "Herton R.
 Krzesinski" <herton@redhat.com>, Alexei Starovoitov <ast@kernel.org>,
 Takashi Iwai <tiwai@suse.com>, "J. Bruce
 Fields" <bfields@fieldses.org>, linux-ide@vger.kernel.org,
 Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
 Jeff Layton <jlayton@poochiereds.net>, Jan Kara <jack@suse.com>,
 Soheil Hassas Yeganeh <soheil@google.com>, linux-s390@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>,
 "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
 Herbert Xu <herbert@gondor.apana.org.au>, linux-scsi@vger.kernel.org,
 Ursula Braun <ubraun@linux.vnet.ibm.com>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, Julian Anastasov <ja@ssi.bg>,
 Ingo
To: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <cover.1494596071.git.mchehab@s-opensource.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Fri, 12 May 2017 10:59:43 -0300
Mauro Carvalho Chehab <mchehab@s-opensource.com> wrote:

> This patch series convert the following books from
> DocBook to ReST:
> 
>    - filesystems
>    - kernel-hacking
>    - kernel-locking
>    - kgdb
>    - libata
>    - networking
>    - rapidio
>    - s390-drivers
>    - scsi
>    - w1
>    - z8530book
> 
> It also adjusts some Sphinx-pedantic errors/warnings on
> some kernel-doc markups.
> 
> I also added some patches here to add PDF output for all
> existing ReST books.

So I've been through the series (including digging out the parts that
weren't sent to me).  

> I did my best to check if what's there is not too outdated, but
> the best is if the subsystem maintainers could check it.

That has been my real concern with those remaining books; many of them
have not been touched in any significant way in at least ten years.  Just
shoveling a bunch of stuff into RST doesn't really solve the problem that
Documentation/ is an unorganized jumble of sometimes highly outdated
documentation.

But, then, I guess there's value in having a disorganized jumble that
depends on only one fragile toolchain rather than two :)  So maybe we
should just do this.

I only had one real comment with the series beyond the general stuff
here.  I see Markus had a few.  When the tweaks are done, can you send me
a series for the stuff I can apply, and I'll do it?

Thanks,

jon
