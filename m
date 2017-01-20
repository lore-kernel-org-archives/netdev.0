From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: restore VIRTIO_HDR_F_DATA_VALID on
	receiving
Date: Fri, 20 Jan 2017 11:03:57 -0500 (EST)
Message-ID: <20170120.110357.940788880370139025.davem@davemloft.net>
References: <1484893962-7614-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rolf.neugebauer@docker.com, netdev@vger.kernel.org, mst@redhat.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1484893962-7614-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 20 Jan 2017 14:32:42 +0800

> Commit 501db511397f ("virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on
> xmit") in fact disables VIRTIO_HDR_F_DATA_VALID on receiving path too,
> fixing this by adding a hint (has_data_valid) and set it only on the
> receiving path.
> 
> Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
