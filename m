From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Prism54 AP WPA using Hostap and WDS
Date: Sun, 7 Nov 2004 18:33:08 -0800
Message-ID: <20041108023308.GA7425@jm.kir.nu>
References: <20041104032219.GU388@ruslug.rutgers.edu>
	<20041105162037.GN388@ruslug.rutgers.edu>
	<20041105162507.GO388@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
Content-Disposition: inline
In-Reply-To: <20041105162507.GO388@ruslug.rutgers.edu>
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

On Fri, Nov 05, 2004 at 11:25:07AM -0500, Luis R. Rodriguez wrote:

> Jouni, Bell Kin sent you some prism54 hostapd patches. I believe you
> actually wrote the work. How are they looking ?

I did not write that code; the copyright notice in driver_prism54.c is
not correct. The code seems to be for older version of hostapd driver
interface API and as such does not work with the current development
snapshot. driver_prism54.c seems to be implemented in a way that would
remove support for Host AP driver, i.e., it does not follow the driver
interface design to allow multiple interfaces and instead just overrides
functions used for Host AP driver. In addition, I did not receive any
patch file for integrating the driver interface code for Prism54.

Someone, ideally the original author, would need to go through these and
submit a proper patch to integrate this into the current development
version of hostapd without breaking other driver interfaces. I'm not
likely to have time to do this myself in the near future, but I'm
willing to comment complete patches and answer questions to get this
into suitable form..

-- 
Jouni Malinen                                            PGP id EFC895FA
