From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: Use NET_IP_ALIGN in acenic
Date: 28 Jul 2004 02:37:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <yq0llh4ab8a.fsf@wildopensource.com>
References: <20040724174348.GL4556@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040724174348.GL4556@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Anton" == Anton Blanchard <anton@samba.org> writes:

Anton> Use NET_IP_ALIGN in acenic driver. Also remove the 16 byte
Anton> padding, caches can be anywhere from 16 to 256 bytes and the
Anton> skb should be cacheline aligned already.

Hi Anton,

I don't have any objections to this one, however the main reason for
the 14 byte padding was to 32 bit align the IP header to avoid too
many misaligned loads rather than hitting any cache boundary.

Cheers,
Jes
