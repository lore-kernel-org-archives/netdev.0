From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 22:15:49 -0400
Message-ID: <1191896149.4373.157.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
	<1191886845.4373.138.camel@localhost> <470AD5D7.1070000@garzik.org>
	<20071008.184126.124062865.davem@davemloft.net>
	<20071009020115.GA14635@gondor.apana.org.au>
	<20071009020318.GA14708@gondor.apana.org.au>
	<20071009020442.GA14746@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jeff@garzik.org, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, gaagaan@gmail.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009020442.GA14746@gondor.apana.org.au>
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

On Tue, 2007-09-10 at 10:04 +0800, Herbert Xu wrote:

> Please revert
> 
> commit 41843197b17bdfb1f97af0a87c06d24c1620ba90
> Author: Jamal Hadi Salim <hadi@cyberus.ca>
> Date:   Tue Sep 25 19:27:13 2007 -0700
> 
>     [NET_SCHED]: explict hold dev tx lock
> 
> As this change introduces potential reordering and I don't think
> we've discussed this aspect sufficiently.

How does it introduce reordering?

cheers,
jamal
