From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [ANNOUNCE] iproute2 version (050929)
Date: Mon, 10 Oct 2005 16:16:03 -0700
Message-ID: <20051010161603.3c96d524@dxpl.pdx.osdl.net>
References: <20050930150406.2e2221fd@dxpl.pdx.osdl.net>
	<Pine.LNX.4.62.0510012332580.14848@bizon.gios.gov.pl>
	<20051005113458.46f0892d@dxpl.pdx.osdl.net>
	<Pine.LNX.4.62.0510101232310.1343@bizon.gios.gov.pl>
	<20051010074002.5cd642da@localhost.localdomain>
	<Pine.LNX.4.62.0510102122120.5659@bizon.gios.gov.pl>
	<1128973355.6327.135.camel@localhost.localdomain>
	<Pine.LNX.4.62.0510102200370.7033@bizon.gios.gov.pl>
	<1128976620.6353.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl,
	Krzysztof Oledzki <olel@ans.pl>
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1128976620.6353.3.camel@localhost.localdomain>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Mon, 10 Oct 2005 16:37:00 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2005-10-10 at 22:08 +0200, Krzysztof Oledzki wrote:
> > 
> 
> > >
> > > Why are you trying to flush those tables?
> > To install a new set of rules.
> > 
> 
> 
> flush should kill everything if i am not mistaken. 
> Are you replacing the main table etc as well?
> 
> > > Try to downgrade the kernel and see what happens - go as far as 2.6.12
> > But why? It works with older (ss050330) version of iproute2 even on 
> > 2.6.13.3.
> > 
> 
> Ok, sorry i wasnt aware of that. Try the attached patch.
> 
> cheers,
> jamal

Look like the -batch code that keeps the RTNL handle open was
breaking this.  The patch shows the general idea, but it still has
problems because I think it would still not work if used in
-batch situation.

-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
