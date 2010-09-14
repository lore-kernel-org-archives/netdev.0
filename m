From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 0/1] macvtap TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 14:05:45 +0200
Message-ID: <20100914120545.GC703@redhat.com>
References: <1284410580.13351.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1284410580.13351.10.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 13, 2010 at 01:43:00PM -0700, Shirley Ma wrote:
> This patch induces a new sock flag ZEROCOPY to avoid copy between
> userspace and kernel. macvtap is the first user of zero copy between
> guest and host kernel. It only uses when the lower device supports high
> memory DMA. The first set of patch only addresses transmission TX side.
> The test has shown big improvement on either CPU utilization reduction
> or BW increase on 10GbE Intel NIC. Performance data will be submitted in
> the coming email.
> 
> thanks
> Shirley

While others pointed out correctness issues with the patch,
I would still like to see the performance numbers, just so we
understand what's possible.

-- 
MST
