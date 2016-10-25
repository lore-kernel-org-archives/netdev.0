From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] virtio-net: Update the mtu code to match virtio spec
Date: Tue, 25 Oct 2016 13:09:29 -0400
Message-ID: <20161025170929.GW42084@redhat.com>
References: <1477413335-17296-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Aaron Conole <aconole@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1477413335-17296-1-git-send-email-aconole@redhat.com>
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

On Tue, Oct 25, 2016 at 12:35:35PM -0400, Aaron Conole wrote:
> From: Aaron Conole <aconole@bytheb.org>
> 
> The virtio committee recently ratified a change, VIRTIO-152, which
> defines the mtu field to be 'max' MTU, not simply desired MTU.
> 
> This commit brings the virtio-net device in compliance with VIRTIO-152.
> 
> Additionally, drop the max_mtu branch - it cannot be taken since the u16
> returned by virtio_cread16 will never exceed the initial value of
> max_mtu.
> 
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Aaron Conole <aconole@redhat.com>

Worksforme.

Acked-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
