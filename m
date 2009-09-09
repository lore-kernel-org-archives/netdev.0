From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: [PATCH] ath5k: do not free irq after resume when
	card has been	removed
Date: Wed, 9 Sep 2009 15:31:40 -0400
Message-ID: <20090909193140.GA17717@hash.localnet>
References: <1252457551-4909-1-git-send-email-cascardo@holoscopio.com>
	<20090909033237.GC13550@hash.localnet>
	<20090909175006.GA7945@vespa.holoscopio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090909175006.GA7945-StA3NKSgq9XYLCA8tIpKU1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 09, 2009 at 02:50:06PM -0300, Thadeu Lima de Souza Cascardo wrote:
> This is against v2.6.31-rc9, so I get a warning with a version that's
> about to get stable. Sorry I am late in the release cycle.

Ok yes, that makes sense then.

> Since this is warning, is this worth backporting to rc?

It's too late probably, but we can send it to stable for 2.6.31.1.

Thank you for the patch by the way, just keep in mind that wireless
patches should be against the wireless-testing kernel in the future.

-- 
Bob Copeland %% www.bobcopeland.com
