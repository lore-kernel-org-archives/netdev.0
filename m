From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/2] virtio-net: Fix two bugs on unloading the module
Date: Thu, 5 Dec 2013 16:54:18 +0200
Message-ID: <20131205145418.GC23147@redhat.com>
References: <1386254181-17257-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Andrey Vagin <avagin@openvz.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1386254181-17257-1-git-send-email-avagin@openvz.org>
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

On Thu, Dec 05, 2013 at 06:36:19PM +0400, Andrey Vagin wrote:
> They can be easy to reproduce, if you try to unload virtio-net
> 
> Andrey Vagin (2):
>   virtio-net: determine type of bufs correctly
>   virtio: delete napi objects from netdev before releasing memory

Thanks a lot for the patches!

>  drivers/net/virtio_net.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> -- 
> 1.8.3.1
