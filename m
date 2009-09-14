From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 29/29] ioat2,	3: cacheline align software descriptor
 allocations
Date: Mon, 14 Sep 2009 16:02:37 +0100
Message-ID: <129600E5E5FB004392DDC3FB599660D7B554819B@irsmsx504.ger.corp.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
 <20090904023257.32667.53926.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932126AbZINPCo@vger.kernel.org>
In-Reply-To: <20090904023257.32667.53926.stgit@dwillia2-linux.ch.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Williams, Dan J wrote:
> All the necessary fields for handling an ioat2,3 ring entry can fit into
> one cacheline.  Move ->len prior to ->txd in struct ioat_ring_ent, and
> move allocation of these entries to a hw-cache-aligned kmem cache to
> reduce the number of cachelines dirtied for descriptor management.
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
