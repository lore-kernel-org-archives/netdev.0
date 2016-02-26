From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/3] basic busy polling support for vhost_net
Date: Fri, 26 Feb 2016 11:45:02 -0500 (EST)
Message-ID: <20160226.114502.171815325392990783.davem@davemloft.net>
References: <1456476164-17242-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.zhang.wz@gmail.com, RAPOPORT@il.ibm.com, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1456476164-17242-1-git-send-email-jasowang@redhat.com>
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
Date: Fri, 26 Feb 2016 16:42:41 +0800

> This series tries to add basic busy polling for vhost net. The idea is
> simple: at the end of tx/rx processing, busy polling for new tx added
> descriptor and rx receive socket for a while. The maximum number of
> time (in us) could be spent on busy polling was specified ioctl.

I'm assuming this will go through Michael's tree.
