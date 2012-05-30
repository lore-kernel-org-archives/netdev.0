From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH repost] virtio-net: remove useless disable on freeze
Date: Wed, 30 May 2012 16:36:05 -0400 (EDT)
Message-ID: <20120530.163605.43003785250138845.davem@davemloft.net>
References: <20120530142128.GA31299@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120530142128.GA31299@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 30 May 2012 17:21:29 +0300

> disable_cb is just an optimization: it
> can not guarantee that there are no callbacks.
> In particular it doesn't have any effect when
> event index is on.
> 
> Instead, detach, napi disable and reset on freeze ensure we don't run
> concurrently with a callback.
> 
> Remove the useless calls so we get same behaviour
> with and without event index.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> Reposting a patch that seems to have fallen through cracks.

It seems to not make it to the lists and get properly picked up
by patchwork.

In any event, I've applied this, thanks.
