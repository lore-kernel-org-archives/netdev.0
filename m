From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 1/1] hyperv: Enable sendbuf mechanism on
 the send path
Date: Wed, 30 Apr 2014 13:36:45 -0400 (EDT)
Message-ID: <20140430.133645.1431735801141049226.davem@davemloft.net>
References: <1398878071-21307-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1398878071-21307-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Wed, 30 Apr 2014 10:14:31 -0700

> We send packets using a copy-free mechanism (this is the Guest to Host transport
> via VMBUS). While this is obviously optimal for large packets,
> it may not be optimal for small packets. Hyper-V host supports
> a second mechanism for sending packets that is "copy based". We implement that
> mechanism in this patch.
> 
> In this version of the patch I have addressed a comment from David Miller.
> 
> With this patch (and all of the other offload and VRSS patches), we are now able
> to almost saturate a 10G interface between Linux VMs on Hyper-V
> on different hosts - close to  9 Gbps as measured via iperf.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
