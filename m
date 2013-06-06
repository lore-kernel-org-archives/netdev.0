From: Tommi Rantala <tt.rantala@gmail.com>
Subject: Re: [PATCH net 0/2] vhost fixes for 3.10
Date: Thu, 6 Jun 2013 21:50:40 +0300
Message-ID: <CA+ydwto07+r2KxGAE=fnBUjs1_hz9CFFJwQrpE0TmAnCu0f8FA@mail.gmail.com>
References: <1370521145-9723-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1370521145-9723-1-git-send-email-mst@redhat.com>
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

2013/6/6 Michael S. Tsirkin <mst@redhat.com>:
> Two patches fixing the fallout from the vhost cleanup in 3.10.
> Thanks to Tommi Rantala who reported the issue.
>
> Tommi, could you please confirm this fixes the crashes for you?

Confirmed! With the two patches applied, I can no longer reproduce the
crash with trinity.

Thanks!

Tommi

> Michael S. Tsirkin (2):
>   vhost: check owner before we overwrite ubuf_info
>   vhost: fix ubuf_info cleanup
>
>  drivers/vhost/net.c   | 26 +++++++++++---------------
>  drivers/vhost/vhost.c |  8 +++++++-
>  drivers/vhost/vhost.h |  1 +
>  3 files changed, 19 insertions(+), 16 deletions(-)
>
> --
> MST
>
