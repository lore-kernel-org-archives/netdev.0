From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [net-next RFC V5 3/5] virtio: intorduce an API to set affinity
	for a virtqueue
Date: Thu, 09 Aug 2012 17:13:37 +0200
Message-ID: <5023D3A1.8040102@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1341484194-8108-4-git-send-email-jasowang@redhat.com>
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

Il 05/07/2012 12:29, Jason Wang ha scritto:
> Sometimes, virtio device need to configure irq affiniry hint to maximize the
> performance. Instead of just exposing the irq of a virtqueue, this patch
> introduce an API to set the affinity for a virtqueue.
> 
> The api is best-effort, the affinity hint may not be set as expected due to
> platform support, irq sharing or irq type. Currently, only pci method were
> implemented and we set the affinity according to:
> 
> - if device uses INTX, we just ignore the request
> - if device has per vq vector, we force the affinity hint
> - if the virtqueues share MSI, make the affinity OR over all affinities
>  requested
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

It looks like both I and Jason will need these patches during the 3.7
merge window, and from different trees (net-next vs. scsi).  How do we
synchronize?

Paolo
