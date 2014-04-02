From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v2 2/2] xen-netback: Grant copy the
 header instead of map and memcpy
Date: Wed, 2 Apr 2014 14:15:12 +0100
Message-ID: <1396444512.8667.340.camel@kazak.uk.xensource.com>
References: <1396278539-27639-1-git-send-email-zoltan.kiss@citrix.com>
	<1396278539-27639-2-git-send-email-zoltan.kiss@citrix.com>
	<1396352440.8667.117.camel@kazak.uk.xensource.com>
	<533C0C9F.8030205@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jonathan.davies@citrix.com, wei.liu2@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul.durrant@citrix.com,
	Zoltan Kiss <zoltan.kiss@citrix.com>, xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <533C0C9F.8030205@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-02 at 14:11 +0100, David Vrabel wrote:

> I'd be in favour of a patch that:
> 
> - renamed gnttab_map_refs() to gnttab_batch_map_pages()
> - refactored it to call gnttab_batch_map().
> - added documentation
> 
> But I don't see why this would be a prerequisite for this series.

No, I think I misunderstoopd the API (because it is confusingly
named...)
> 
> David
