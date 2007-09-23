From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [ofa-general] Re: [PATCHES] TX batching
Date: Sun, 23 Sep 2007 12:36:57 -0700
Message-ID: <46F6C059.6000600@intel.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<46F6AE18.7080708@garzik.org> <1190574713.5030.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, Jeff Garzik <jeff@garzik.org>,
	rdreier@cisco.com, mcarlson@broadcom.com,
	general@lists.openfabrics.org, sri@us.ibm.com, jagana@us.ibm.com,
	mchan@broadcom.com, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, David Miller <davem@davemloft.net>
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-reply-to: <1190574713.5030.4.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sun, 2007-23-09 at 14:19 -0400, Jeff Garzik wrote:
> 
>> You should post at least a couple driver patches to see how its used on 
>> Real Hardware(tm)...   :)
> 
> This is the tg3 patch i used for the testing - against whats in Daves
> net-2.6.24 tree. Patch may be a bit hard to read.
> For an example of an LLTX version look at the e1000 in the older git
> tree at:
> git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git
> 
> If the intel folks will accept the patch i'd really like to kill 
> the e1000 LLTX interface.
> The tg3 in that tree used the old style batch_xmit() interface.

please be reminded that we're going to strip down e1000 and most of the features
should go into e1000e, which has much less hardware workarounds. I'm still
reluctant to putting in new stuff in e1000 - I really want to chop it down first ;)

AUke
