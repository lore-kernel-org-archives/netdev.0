From: "Christopher S. Aker" <caker@theshore.net>
Subject: Re: xen-netback: fix oopes during shutdown and error
 handling
Date: Thu, 14 Feb 2013 16:57:51 -0500
Message-ID: <511D5DDF.7040000@theshore.net>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, xen-devel@lists.xen.org,
	Jan Beulich <jbeulich@suse.com>, Wei Liu <wei.liu@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On 2/14/13 8:18 AM, David Vrabel wrote:
> These two netback patches fix oopes that may occur during shutdown or
> if a specific fatal error occurs.

On 2/14/13 11:39 AM, Ian Campbell wrote:
> Although I would like to add a Tested-by: Christopher too if
> possible.

Tested-by: Christopher S. Aker <caker@theshore.net> (and team)

We are no longer able to trigger the last OOPs we provided by downing 
the vif.  Further testing of the other issues will take time, but we're 
deploying a few patched hosts now.

Thanks!
-Chris
