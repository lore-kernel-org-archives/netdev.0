From: Christoph Hellwig <hch@infradead.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Tue, 3 Jul 2007 08:15:30 +0100
Message-ID: <20070703071530.GA25369@infradead.org>
References: <1183238694.9055.10.camel@blaa>
	<08FE5CC30C9A3F41BF819A502CF7BF6E019416BA@fmsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok,  Auke-jan H" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jason Lunz <lunz@reflexsecurity.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <08FE5CC30C9A3F41BF819A502CF7BF6E019416BA@fmsmsx411.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 04:52:52PM -0700, Williams, Mitch A wrote:
> - We include e1000new in 2.6.23, along side e1000.  We expose ICH9
>   device IDs in e1000new, and gate the rest of the IDs inside
>   #ifndef CONFIG_E1000.

No.  Hardware support in one driver should never be affected by config
options in another drivers.

Also I really think there shouldn't be one single driver for all the
hardware as outlined by intel people in this thread.  I'd say add a new
e1000e driver for all the pci-e hardware and have a temporary config
option to disable those device already supported by the existing e1000
driver.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
