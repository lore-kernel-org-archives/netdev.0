From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for
	ndo_ll_poll
Date: Tue, 21 May 2013 10:06:43 +0300
Message-ID: <1369120003.25971.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<20130520101622.14133.21998.stgit@ladj378.jer.intel.com>
	<CAJZOPZJx8vpSWqOhmN65gn=vi7hWXQO_J01+hAwGY9RwetX3DA@mail.gmail.com>
	<519B1A2B.4010909@linux.intel.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, HPA <hpa@zytor.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: "Eliezer Tamir" <eliezer.tamir@linux.intel.com>,
	"Or Gerlitz" <or.gerlitz@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <519B1A2B.4010909@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 09:54 +0300, Eliezer Tamir wrote:
> On 20/05/2013 23:20, Or Gerlitz wrote:
> > On Mon, May 20, 2013 at 1:16 PM, Eliezer Tamir
> > <eliezer.tamir@linux.intel.com> wrote:
> >> Add the ixgbe driver code implementing ndo_ll_poll.
> >> It should be easy for other drivers to do something similar
> >> in order to enable support for CONFIG_INET_LL_RX_POLL
> >
> > I am not sure,
> 
> Willem ported this to <some undisclosed HW that they use at Google>, his 
> feedback was that it was not a major effort.

We also played with applying a similar patch on the bnx2x and it looks
great :) - Thanks Eliezer!

Or - at least for the bnx2x, it is easy to add support for this new ndo.

Hopefully this series will be accepted so we can send follow up support
for the bnx2x as well.

Thanks,
Eilon




------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
