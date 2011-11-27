From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-net: Acquire device lock when releasing device
Date: Sun, 27 Nov 2011 18:50:14 +0200
Message-ID: <20111127165013.GB24941@redhat.com>
References: <1321607982-16283-1-git-send-email-levinsasha928@gmail.com>
	<20111126.154503.1317670837061338352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111126.154503.1317670837061338352.davem@davemloft.net>
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

On Sat, Nov 26, 2011 at 03:45:03PM -0500, David Miller wrote:
> From: Sasha Levin <levinsasha928@gmail.com>
> Date: Fri, 18 Nov 2011 11:19:42 +0200
> 
> > Device lock should be held when releasing a device, and specifically
> > when calling vhost_dev_cleanup(). Otherwise, RCU complains about it:
>  ...
> > Cc: "Michael S. Tsirkin" <mst@redhat.com>
> > Cc: kvm@vger.kernel.org
> > Cc: virtualization@lists.linux-foundation.org
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> 
> Michael et al., are you guys going to gather this fix or should I
> apply it directly to thet net tree?
> 
> Thanks.

I think it needs a small tweak before being applied.

-- 
MST
