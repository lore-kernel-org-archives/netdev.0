From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 1/1] hv_netvsc: Properly size the vrss queues
Date: Sat, 30 May 2015 17:39:00 -0700 (PDT)
Message-ID: <20150530.173900.1466293770301543958.davem@davemloft.net>
References: <1432757817-6804-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1432757817-6804-1-git-send-email-kys@microsoft.com>
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

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Wed, 27 May 2015 13:16:57 -0700

> The current algorithm for deciding on the number of VRSS channels is
> not optimal since we open up the min of number of CPUs online and the
> number of VRSS channels the host is offering. So on a 32 VCPU guest
> we could potentially open 32 VRSS subchannels. Experimentation has
> shown that it is best to limit the number of VRSS channels to the number
> of CPUs within a NUMA node.
> 
> Here is the new algorithm for deciding on the number of sub-channels we
> would open up:
>         1) Pick the minimum of what the host is offering and what the driver
>            in the guest is specifying as the default value.
>         2) Pick the minimum of (1) and the numbers of CPUs in the NUMA
>            node the primary channel is bound to.
> 
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
