From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Wed, 14 Mar 2012 01:05:57 -0700
Message-ID: <1331712357.2456.58.camel@edumazet-laptop>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	 <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
	 <1331658828.4449.16.camel@edumazet-glaptop>
	 <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
	 <1331704535.2456.37.camel@edumazet-laptop>
	 <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
 kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
 x86@kernel.org,  arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
 mingo@redhat.com, oleg@redhat.com,  peterz@infradead.org,
 rdunlap@xenotime.net, mcgrathr@chromium.org,  tglx@linutronix.de,
 luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
 djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
 akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
 coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <kernel-hardening-return-1114-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
List-Id: netdev.vger.kernel.org

Le mercredi 14 mars 2012 à 08:59 +0100, Indan Zupancic a écrit :

> The only remaining question is, is it worth the extra code to release
> up to 32kB of unused memory? It seems a waste to not free it, but if
> people think it's not worth it then let's just leave it around.

Quite frankly its not an issue, given JIT BPF is not yet default
enabled.

I am not sure all bugs were found and fixed. I would warn users before
considering using it in production.

If you have time, I would appreciate if you could double check and find
last bugs in it.
