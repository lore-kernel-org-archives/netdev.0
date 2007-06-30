From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RFR: New e1000 driver (e1000new),
	was: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 20:32:34 -0700
Message-ID: <ada8xa29kx9.fsf@cisco.com>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>
	<46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org> <468594B7.6070309@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, "Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Jason Lunz <lunz@reflexsecurity.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468594B7.6070309@intel.com> (Auke Kok's message of "Fri,
	29 Jun 2007 16:24:39 -0700")
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

one possibility would be to merge e1000new with support only for chips
not supported by e1000, and semi-freeze e1000 (fixes only, new device
support goes into e1000new).  Then if there are some devices that are
more naturally supported by e1000new, we could later on merge patches
to move support for those devices from e1000 to e1000new.  Presumably
this would simplify e1000, since it would have to support a smaller
set of older devices.  e1000new would stay relatively clean too since
it wouldn't have to handle anything too old.

And at every stage of the process, any given NIC would have only one
driver in the tree.

 - R.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
