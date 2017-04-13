From: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Subject: RE: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Thu, 13 Apr 2017 09:10:32 +0000
Message-ID: <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>
References: <20170401.112603.1991545644693496714.davem@davemloft.net>
 <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dingtianhong <dingtianhong@huawei.com>, Will Deacon <will.deacon@arm.com>,
 Linuxarm <linuxarm@huawei.com>,
 "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
 "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Robin Murphy <Robin.Murphy@arm.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi David

> -----Original Message-----
> Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
> ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
> Date: Sat, 1 Apr 2017 11:26:03 -0700
> From: David Miller <davem@davemloft.net>
> To: dingtianhong@huawei.com
> CC: catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com,
> robin.murphy@arm.com, jeffrey.t.kirsher@intel.com,
> alexander.duyck@gmail.com, linux-arm-kernel@lists.infradead.org,
> netdev@vger.kernel.org
> 
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Sat, 1 Apr 2017 15:25:51 +0800
> 
> > Till now only the Intel ixgbe could support enable
> > Relaxed ordering in the drivers for special architecture,
> > but the ARCH_WANT_RELAX_ORDER is looks like a general name
> > for all arch, so rename to a specific name for intel
> > card looks more appropriate.
> >
> > Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> This is not a driver specific facility.
> 
> Any driver can test this symbol and act accordingly.
> 
> Just because IXGBE is the first and only user, doesn't mean
> the facility is driver specific.


Please correct me if I am wrong but my understanding is that the standard
way to enable/disable relaxed ordering is to set/clear bit 4 of the Device
Control Register (PCI_EXP_DEVCTL_RELAX_EN 0x0010 /* Enable relaxed
ordering */).
Now I have looked up for all drivers either enabling or disabling relaxed
ordering and none of them seems to need a symbol to decide whether to
enable it or not.
Also it seems to me enabling/disabling relaxed ordering is never bound to the
host architecture.

So why this should be (or it is expected to be) a generic symbol?
Wouldn't it be more correct to have this as a driver specific symbol now and
move it to a generic one later once we have other drivers requiring it?
  
Many thanks
Gab

> 
> Thank you.
> 
> .
> 
