From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan Users] 	DPD Problem - message from kernel malformed:
	unknown address family
Date: Thu, 21 Oct 2004 09:24:52 +1000
Sender: users-bounces@openswan.org
Message-ID: <20041020232452.GA9803@gondor.apana.org.au>
References: <417675C6.3040704@gmx.ch>
	<E1CKOXc-0002Kq-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <users-bounces@openswan.org>
To: Eric Marchionni <mailing-lists@gmx.ch>
Content-Disposition: inline
In-Reply-To: <E1CKOXc-0002Kq-00@gondolin.me.apana.org.au>
Cc: users@openswan.org
Cc: davem@davemloft.net
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/users>,
	<mailto:users-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/users>
List-Post: <mailto:users@openswan.org>
List-Help: <mailto:users-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/users>,
	<mailto:users-request@openswan.org?subject=subscribe>
Errors-To: users-bounces@openswan.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 21, 2004 at 08:02:44AM +1000, Herbert Xu wrote:
> Eric Marchionni <mailing-lists@gmx.ch> wrote:
> > 
> > the ping times out and this occurs in the log:
> > Oct 20 10:36:11 localhost pluto[12528]: XFRM_MSG_ACQUIRE message from 
> > kernel malformed: unknown address family
> 
> Looks like nobody has tested shunt routes for a while.

Alright I just tested it with 2.6.9 with the latest openswan and I
can't reproduce this problem.  I brought the connection up with
auto --route and initiated the connection by a ping packet.

Which kernel/openswan are you using?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
