From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] timer: Provide wrappers safe for use with LOCKDEP
Date: Fri, 20 Oct 2017 00:52:30 -0700
Message-ID: <20171020075230.GA31536@infradead.org>
References: <20171019202838.GA43223@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Craig Gallek <cgallek@google.com>,
        Eric Dumazet <edumazet@google.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171019202838.GA43223@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 19, 2017 at 01:28:38PM -0700, Kees Cook wrote:
> Under LOCKDEP, the timer lock_class_key (set up in __setup_timer) needs
> to be tied to the caller's context, so an inline for timer_setup()
> won't work. We do, however, want to keep the inline version around for
> argument type checking, though, so this provides macro wrappers in the
> LOCKDEP case.

Heh, when I tried to do inline setup_timer Arnd had actually pointed
that out in the review.. 
