From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Sat, 12 Feb 2005 16:18:14 -0800
Message-ID: <527jld2tyx.fsf@topspin.com>
References: <20050212232518.10838.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, arjan@infradead.org, bunk@stusta.de, chrisw@osdl.org,
        davem@redhat.com, hlein@progressive-comp.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shemminger@osdl.org,
        Valdis.Kletnieks@vt.edu
To: linux@horizon.com
In-Reply-To: <20050212232518.10838.qmail@science.horizon.com> (linux@horizon.com's
 message of "12 Feb 2005 23:25:18 -0000")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    linux> It's easy to make a smaller hash by just thowing bits away,
    linux> but a block cipher is a permutation, and has to be
    linux> invertible.

    linux> For example, if I take a k-bit counter and encrypt it with
    linux> a k-bit block cipher, the output is guaranteed not to
    linux> repeat in less than 2^k steps, but the value after a given
    linux> value is hard to predict.

Huh?  What if my cipher consists of XOR-ing with a k-bit pattern?
That's a permutation on the set of k-bit blocks but it happens to
decompose as a product of (non-overlapping) swaps.

In general for more realistic block ciphers like DES it seems
extremely unlikely that the cipher has only a single orbit when viewed
as a permutation.  I would expect a real block cipher to behave more
like a random permutation, which means that the expected number of
orbits for a k-bit cipher should be about ln(2^k) or roughly .7 * k.

 - R.
