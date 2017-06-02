From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] virtio_net: lower limit on buffer size
Date: Fri, 02 Jun 2017 14:32:54 -0400 (EDT)
Message-ID: <20170602.143254.1054389009843287751.davem@davemloft.net>
References: <1496415192-17031-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, bfields@fieldses.org,
	mpatocka@redhat.com
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1496415192-17031-1-git-send-email-mst@redhat.com>
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
Date: Fri, 2 Jun 2017 17:54:33 +0300

> commit d85b758f72b0 ("virtio_net: fix support for small rings")
> was supposed to increase the buffer size for small rings but had an
> unintentional side effect of decreasing it for large rings. This seems
> to break some setups - it's not yet clear why, but increasing buffer
> size back to what it was before helps.
> 
> Fixes: d85b758f72b0 ("virtio_net: fix support for small rings")
> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> Tested-by: Mikulas Patocka <mpatocka@redhat.com>
> Tested-by: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> Patch tested, pls merge.
> 
> changes from v2:
> 	commit log tweaks to address comments by Sergei Shtylyov

Applied, thanks Michael.
