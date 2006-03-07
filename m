From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Tue, 7 Mar 2006 13:49:07 -0800
Message-ID: <20060307134907.733d3d27@localhost.localdomain>
References: <OF336D72E6.999D2A30-ON8725712A.00117C92-8825712A.00116629@us.ibm.com>
	<1141767891.6119.903.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	openib-general@openib.org, "David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
In-Reply-To: <1141767891.6119.903.camel@localhost>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Mar 2006 13:44:51 -0800
Matt Leininger <mlleinin@hpcn.ca.sandia.gov> wrote:

> On Mon, 2006-03-06 at 19:13 -0800, Shirley Ma wrote:
> > 
> > > More likely you are getting hit by the fact that TSO prevents the
> > congestion
> > window from increasing properly. This was fixed in 2.6.15 (around mid
> > of Nov 2005). 
> > 
> > Yep, I noticed the same problem. After updating to the new kernel, the
> > performance are much better, but it's still lower than before.
> 
>  Here is an updated version of OpenIB IPoIB performance for various
> kernels with and without one of the TSO patches.  The netperf
> performance for the latest kernels has not improved the TSO performance
> drop.
> 
>   Any comments or suggestions would be appreciated.
> 
>   - Matt

Configuration information? like did you increase the tcp_rmem, tcp_wmem?
Tcpdump traces of what is being sent and available window?
Is IB using NAPI or just doing netif_rx()?
