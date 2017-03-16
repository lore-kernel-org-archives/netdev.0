From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Thu, 16 Mar 2017 12:10:32 -0700 (PDT)
Message-ID: <20170316.121032.405930218798336643.davem@davemloft.net>
References: <1489678147-21404-8-git-send-email-elena.reshetova@intel.com>
	<1489683534.28631.231.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAGXu5jJpFwiDR_o=oarN_2vDr56cwQ=Bg-5NikUmDtxtzWnAcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, peterz@infradead.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org, ishkamiel@gmail.com, kuznet@ms2.inr.ac.ru,
	kaber@trash.net, elena.reshetova@intel.com, dwindsor@gmail.com
To: keescook@chromium.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAGXu5jJpFwiDR_o=oarN_2vDr56cwQ=Bg-5NikUmDtxtzWnAcQ@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Thu, 16 Mar 2017 11:38:25 -0600

> I am, of course, biased, but I think the evidence of actual
> refcounting attacks outweighs the theoretical performance cost of
> these changes.

This is not theoretical at all.

We count the nanoseconds that every packet takes to get processed and
you are adding quite a bit.

I understand your point of view, but this is knowingly going to add
performance regressions to the networking code.
