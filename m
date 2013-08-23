From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 19:17:05 +0200
Message-ID: <52179911.9030705@gmail.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-4-git-send-email-zonque@gmail.com> <52177052.1030308@ti.com> <52178E20.5040404@gmail.com> <52179448.1020906@ti.com> <5217974B.5090503@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>,
	netdev@vger.kernel.org, bcousson@baylibre.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <5217974B.5090503@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.08.2013 19:09, Sekhar Nori wrote:
> On 8/23/2013 10:26 PM, Santosh Shilimkar wrote:

>> So just stick the IP version or call it cpsw-v1... cpsw-v2 etc.
> 
> If this could be handled using IP version then the right way would be to
> just read the IP version from hardware and use it. No need of DT property.

Yes, exactly. The information we need to support the phy interface
setting is completely disconnected from the cpsw core itself.


Daniel
