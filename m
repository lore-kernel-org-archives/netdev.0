From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Fri, 07 Nov 2014 16:48:59 -0500 (EST)
Message-ID: <20141107.164859.951682597018909290.davem@redhat.com>
References: <20141105210745.GT7996@ZenIV.linux.org.uk>
	<20141105.165719.835728206041332333.davem@davemloft.net>
	<20141106032533.GU7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141106032533.GU7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Thu, 6 Nov 2014 03:25:34 +0000

> OK, I've taken the beginning of the old queue on top of net-next; it's
> in git://git.kernel.org//pub/scm/linux/kernel/git/viro/vfs.git iov_iter-net.

What I see in there looks good.   I wonder if we can somehow make msghdr
pointer args const... but this is not so important now.

Some minor coding style nits, comments:

	/* Like
	 * this.
	 */

and for multi-line function calls in the networking, align the second
and subsequent lines at the first column after the openning parenthesis
of the first line.

Thanks.
