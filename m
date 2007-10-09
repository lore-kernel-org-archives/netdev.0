From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 09:10:02 -0400
Message-ID: <1191935402.4373.172.camel@localhost>
References: <OFDE12F216.8E927E22-ON6525736F.001137D0-6525736F.00115A01@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OFDE12F216.8E927E22-ON6525736F.001137D0-6525736F.00115A01@in.ibm.com>
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

On Tue, 2007-09-10 at 08:39 +0530, Krishna Kumar2 wrote:

> Driver might ask for 10 and we send 10, but LLTX driver might fail to get
> lock and return TX_LOCKED. I haven't seen your code in greater detail, but
> don't you requeue in that case too?

For others drivers that are non-batching and LLTX, it is possible - at
the moment in my patch i whine that the driver is buggy. I will fix this
up so it checks for NETIF_F_BTX. Thanks for pointing the above use case.

cheers,
jamal
