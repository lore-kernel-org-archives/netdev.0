From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Prism54 AP WPA using Hostap and WDS
Date: Sun, 7 Nov 2004 21:25:48 -0800
Message-ID: <20041108052548.GA30250@jm.kir.nu>
References: <20041104032219.GU388@ruslug.rutgers.edu>
	<20041105162037.GN388@ruslug.rutgers.edu>
	<20041105162507.GO388@ruslug.rutgers.edu>
	<20041108023308.GA7425@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
Content-Disposition: inline
In-Reply-To: <20041108023308.GA7425@jm.kir.nu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 07, 2004 at 06:33:08PM -0800, Jouni Malinen wrote:

> Someone, ideally the original author, would need to go through these and
> submit a proper patch to integrate this into the current development
> version of hostapd without breaking other driver interfaces.

Thanks to quick reply from Bell Kin, I now have such a patch. I did some
more cleanup and committed this to Host AP/hostapd CVS (development
branch). I have not yet tested this apart from verifying that it
compiles, so I may have broken something in the cleanup. Test reports
using the latest CVS development snapshot from http://hostap.epitest.fi/
are welcome. Please note that you will need to make .config file with
CONFIG_DRIVER_PRISM54=y in hostapd directory in order to build Prism54
driver interface.

-- 
Jouni Malinen                                            PGP id EFC895FA
