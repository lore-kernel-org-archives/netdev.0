From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] virtio_net: fix PAGE_SIZE > 64k
Date: Tue, 24 Jan 2017 14:42:27 -0500 (EST)
Message-ID: <20170124.144227.2017106704873029028.davem@davemloft.net>
References: <1485197869-11350-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1485197869-11350-1-git-send-email-mst@redhat.com>
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
Date: Mon, 23 Jan 2017 21:37:52 +0200

> I don't have any guests with PAGE_SIZE > 64k but the
> code seems to be clearly broken in that case
> as PAGE_SIZE / MERGEABLE_BUFFER_ALIGN will need
> more than 8 bit and so the code in mergeable_ctx_to_buf_address
> does not give us the actual true size.
> 
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks Michael.

I am really trying to be patient, but we are about to run out of
time for fixing the adjust header XDP stuff.

That should have been resolved in a week or two, but now we're
basically a month or so later.

Please come to some kind of agreement about how to implement this
because we can't let v4.10 go out without this being resolved.

Thank you.
