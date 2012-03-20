From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: bpf_jit: Simplify code by always using offset8 or
 offset32.
Date: Tue, 20 Mar 2012 06:56:17 -0700
Message-ID: <1332251777.7893.4.camel@edumazet-glaptop>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	 <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
	 <1331658828.4449.16.camel@edumazet-glaptop>
	 <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
	 <1331704535.2456.37.camel@edumazet-laptop>
	 <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
	 <1331712357.2456.58.camel@edumazet-laptop>
	 <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
	 <1331992184.2466.45.camel@edumazet-laptop>
	 <9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
	 <1332075121.3722.34.camel@edumazet-laptop>
	 <371a1925e68e68f873e30381e0fa60ea.squirrel@webmail.greenhost.nl>
	 <1332212386.22737.20.camel@edumazet-glaptop>
	 <cfb04c3fe59e421093f035c035c88b51.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <cfb04c3fe59e421093f035c035c88b51.squirrel@webmail.greenhost.nl>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-03-20 at 22:33 +1100, Indan Zupancic wrote:

> And if the dev, len or data_len fields are really moved past the first
> 127 bytes the JIT code can be changed too. The JIT code already depends
> on some of struct sk_buff's field properties anyway.

Its seems you didnt understand, but I said NO to your patch.

This time I am really tired.
