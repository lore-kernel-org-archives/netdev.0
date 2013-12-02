From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] virtio-net: make all RX paths handle erors
	consistently
Date: Sun, 01 Dec 2013 20:28:20 -0500 (EST)
Message-ID: <20131201.202820.1535300264634944655.davem@davemloft.net>
References: <1385638044-27467-1-git-send-email-mst@redhat.com>
	<1385638044-27467-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1385638044-27467-2-git-send-email-mst@redhat.com>
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
Date: Thu, 28 Nov 2013 13:30:59 +0200

> receive mergeable now handles errors internally.
> Do same for big and small packet paths, otherwise
> the logic is too hard to follow.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Jason Wang <jasowang@redhat.com>

Applied and I fixed the subject text to use an underscore '_' instead
of a dash '-' for "virtio_net: ".
