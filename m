From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v2] tools: hv: Add a script to help bonding
 synthetic and VF NICs
Date: Fri, 10 Jun 2016 18:13:36 -0700 (PDT)
Message-ID: <20160610.181336.132305021219588924.davem@davemloft.net>
References: <1465593792-31672-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1465593792-31672-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri, 10 Jun 2016 14:23:12 -0700

> This script helps to create bonding network devices based on synthetic NIC
> (the virtual network adapter usually provided by Hyper-V) and the matching
> VF NIC (SRIOV virtual function). So the synthetic NIC and VF NIC can
> function as one network device, and fail over to the synthetic NIC if VF is
> down.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
> v2: Make it to be distro neutral.

This tool doesn't configure anything.

It fishes information out of sysfs and prints it out.

I don't think this is useful, not appropriate for the kernel
tools subdirectory at all.

When I said make it distro neutral, that meant if you wanted to submit
this again you were expected to do the hard work of making it
configure things properly on all major distributions.
