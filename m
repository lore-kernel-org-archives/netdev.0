From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 11/16] virtio_net: minor cleanup
Date: Mon, 6 Oct 2014 14:06:40 +0200
Message-ID: <20141006140640.36ff345f.cornelia.huck@de.ibm.com>
References: <1412525038-15871-1-git-send-email-mst@redhat.com>
	<1412525038-15871-12-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1412525038-15871-12-git-send-email-mst@redhat.com>
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

On Sun, 5 Oct 2014 19:07:21 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> 	goto done;
> done:
> 	return;
> is ugly, it was put there to make diff review easier.
> replace by open-coded return.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 

If you don't want to merge it into the mutex removal patch, maybe move
it one up in the series?

Acked-by: Cornelia Huck <cornelia.huck@de.ibm.com>
