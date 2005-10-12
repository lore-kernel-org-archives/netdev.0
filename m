From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [ANNOUNCE] iproute2 version (050929)
Date: Wed, 12 Oct 2005 15:32:46 -0700
Message-ID: <20051012153246.6e4e7bdd@dxpl.pdx.osdl.net>
References: <20050930150406.2e2221fd@dxpl.pdx.osdl.net>
	<Pine.LNX.4.62.0510012332580.14848@bizon.gios.gov.pl>
	<20051005113458.46f0892d@dxpl.pdx.osdl.net>
	<Pine.LNX.4.62.0510101232310.1343@bizon.gios.gov.pl>
	<20051010074002.5cd642da@localhost.localdomain>
	<Pine.LNX.4.62.0510102122120.5659@bizon.gios.gov.pl>
	<1128973355.6327.135.camel@localhost.localdomain>
	<Pine.LNX.4.62.0510102200370.7033@bizon.gios.gov.pl>
	<1128976620.6353.3.camel@localhost.localdomain>
	<20051010161603.3c96d524@dxpl.pdx.osdl.net>
	<1128990692.6353.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl,
	Krzysztof Oledzki <olel@ans.pl>
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1128990692.6353.14.camel@localhost.localdomain>
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

On Mon, 10 Oct 2005 20:31:31 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2005-10-10 at 16:16 -0700, Stephen Hemminger wrote:
> 
> > Look like the -batch code that keeps the RTNL handle open was
> > breaking this.  The patch shows the general idea, but it still has
> > problems because I think it would still not work if used in
> > -batch situation.
> 
> I see what you mean.
> You definitely need at least one extra socket for deleting
> in the flush_rule(). Something like the attached, untested,
> uncompiled.
> 
> 
> Krzysztof, if you have time please try the attached patch?
> 
> cheers,
> jamal

applied to iproute2 cvs

-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
