From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] virtio_net: fix use after free
Date: Fri, 31 Oct 2014 05:24:13 -0700
Message-ID: <1414758253.499.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413378878-28118-1-git-send-email-mst@redhat.com>
	<1414726609.499.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<5453270F.3090300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5453270F.3090300@redhat.com>
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

On Fri, 2014-10-31 at 14:07 +0800, Jason Wang wrote:

> Since they are called before the possible free_old_xmit_skbs(), skb
> won't get freed at this time.

Oh right, I forgot there is no completion handler yet, timer based or
whatever.

Thanks.
