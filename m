From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] hostap_plx: fix CIS verification
Date: Tue, 24 Oct 2006 18:44:48 -0700
Message-ID: <20061025014447.GA6121@jm.kir.nu>
References: <1161382815.5803.2.camel@dv> <20061021011943.GC6140@jm.kir.nu>
	<20061025003707.GB7340@tuxdriver.com> <1161737289.29298.6.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1161737289.29298.6.camel@dv>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2006 at 08:48:09PM -0400, Pavel Roskin wrote:

> I don't have Coverity to check, and I think the results of Coverity were
> misinterpreted.  It doesn't know anything about CIS structure.  Anyway,
> let me just check Jouni's suggestion on a real PLX card.

It doesn't need to know anything about the CIS structure. The driver
must not be allowed to run over a buffer even if given an invalid CIS
data.
 
-- 
Jouni Malinen                                            PGP id EFC895FA
