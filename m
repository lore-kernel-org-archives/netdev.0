From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] once: switch to new jump label API
Date: Tue, 22 Aug 2017 14:44:41 -0400
Message-ID: <874lszmoh2.fsf@stressinduktion.org>
References: <20170821234241.88438-1-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jason Baron <jbaron@akamai.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Eric Biggers <ebiggers@google.com>
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821234241.88438-1-ebiggers3@gmail.com> (Eric Biggers's
        message of "Mon, 21 Aug 2017 16:42:41 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Biggers <ebiggers3@gmail.com> writes:

> From: Eric Biggers <ebiggers@google.com>
>
> Switch the DO_ONCE() macro from the deprecated jump label API to the new
> one.  The new one is more readable, and for DO_ONCE() it also makes the
> generated code more icache-friendly: now the one-time initialization
> code is placed out-of-line at the jump target, rather than at the inline
> fallthrough case.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org.

Thanks!
