From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Tue, 25 Apr 2017 10:47:31 -0400 (EDT)
Message-ID: <20170425.104731.631398016575024152.davem@davemloft.net>
References: <20170425140809.23881-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David.Laight@aculab.com, kernel-hardening@lists.openwall.com
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170425140809.23881-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 25 Apr 2017 16:08:05 +0200

> This is a defense-in-depth measure in response to bugs like
> 4d6fa57b4dab0d77f4d8e9d9c73d1e63f6fe8fee.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Please refer to commits in the form:

$(SHA1_ID) ("Commit header line.")

That is, 12 bytes of SHA1_ID followed by the commit header line text
in both double quotes and parenthesis, like this:

4d6fa57b4dab ("macsec: avoid heap overflow in skb_to_sgvec")

Otherwise when changes get backported or applied to different trees,
they have different SHA1_ID values.  The commit header text removes
any and all ambiguity.

Thank you.
