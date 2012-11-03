From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/8] enable/disable zero copy tx dynamically
Date: Fri, 02 Nov 2012 21:31:10 -0400 (EDT)
Message-ID: <20121102.213110.2070365320544608145.davem@davemloft.net>
References: <cover.1351797353.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, alexander.h.duyck@intel.com, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	akpm@linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1351797353.git.mst@redhat.com>
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
Date: Thu, 1 Nov 2012 21:16:17 +0200

> 
> tun supports zero copy transmit since 0690899b4d4501b3505be069b9a687e68ccbe15b,
> however you can only enable this mode if you know your workload does not
> trigger heavy guest to host/host to guest traffic - otherwise you
> get a (minor) performance regression.
> This patchset addresses this problem by notifying the owner
> device when callback is invoked because of a data copy.
> This makes it possible to detect whether zero copy is appropriate
> dynamically: we start in zero copy mode, when we detect
> data copied we disable zero copy for a while.
> 
> With this patch applied, I get the same performance for
> guest to host and guest to guest both with and without zero copy tx.

Series applied, thanks Michael.
