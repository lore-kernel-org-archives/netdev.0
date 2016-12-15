From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 3/3] random: use siphash24 instead of md5 for
 get_random_int/long
Date: Thu, 15 Dec 2016 10:14:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02401A1@AcuExch.aculab.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <20161214184605.24006-1-Jason@zx2c4.com>
 <20161214184605.24006-3-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Ted Tso <tytso@mit.edu>
To: "'Jason A. Donenfeld'" <Jason@zx2c4.com>,
        Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161214184605.24006-3-Jason@zx2c4.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Behalf Of Jason A. Donenfeld
> Sent: 14 December 2016 18:46
...
> +	ret = *chaining = siphash24((u8 *)&combined, offsetof(typeof(combined), end),

If you make the first argument 'const void *' you won't need the cast
on every call.

I'd also suggest making the key u64[2].

	David
