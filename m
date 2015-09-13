From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH v2] atomics,cmpxchg: Privatize the inclusion of
 asm/cmpxchg.h
Date: Sun, 13 Sep 2015 15:47:40 -0700
Message-ID: <20150913224740.GF19736@linux-q0g1.site>
References: <1441762024-2081-1-git-send-email-boqun.feng@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Will Deacon <will.deacon@arm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Shradha Shah <sshah@solarflare.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	William Hubbs <w.d.hubbs@gmail.com>,
	Chris Brannon <chris@the-brannons.com>,
	Kirk Reiser <kirk@reisers.ca>,
	Samuel Thibault <samuel.thibault@ens-lyon.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Aybuke Ozdemir <aybuke.147@gmail.com>,
	linux-net-drivers@solarflare.com, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, speakup@linux-speakup.org,
	devel@driverdev.osuosl.org
To: Boqun Feng <boqun.feng@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441762024-2081-1-git-send-email-boqun.feng@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 Sep 2015, Boqun Feng wrote:

>After commit:
>
>atomics: add acquire/release/relaxed variants of some atomic operations
>
>Architectures may only provide {cmp,}xchg_relaxed definitions in
>asm/cmpxchg.h. Other variants, such as {cmp,}xchg, may be built in
>linux/atomic.h, which means simply including asm/cmpxchg.h may not get
>the definitions of all the{cmp,}xchg variants. Therefore, we should
>privatize the inclusions of asm/cmpxchg.h to keep it only included in
>arch/* and replace the inclusions outside with linux/atomic.h
>
>Acked-by: Will Deacon <will.deacon@arm.com>
>Signed-off-by: Boqun Feng <boqun.feng@gmail.com>

fwiw,

Acked-by: Davidlohr Bueso <dave@stgolabs.net>
