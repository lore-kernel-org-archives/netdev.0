From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v1 1/2] bridge: export port_no and
 port_id via IFA_INFO_DATA
Date: Fri, 30 Nov 2012 22:51:25 +0800
Message-ID: <1354287085.19865.3.camel@cr0>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
	<20121130101814.GD30697@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121130101814.GD30697@casper.infradead.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-11-30 at 10:18 +0000, Thomas Graf wrote:
> On 11/30/12 at 05:58pm, Cong Wang wrote:
> > @@ -168,6 +172,8 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
> >  	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
> >  	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
> >  	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
> > +	[IFLA_BRPORT_NO]	= { .type = NLA_U16 },
> > +	[IFLA_BRPORT_ID]	= { .type = NLA_U16 },
> >  };
> >  
> >  /* Change the state of the port and notify spanning tree */
> 
> I missed this in the first round. Not much of a point in adding policy
> entries if the attributes are read-only as in this case.

Yeah, remove these lines now.
