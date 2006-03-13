From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Mon, 13 Mar 2006 13:50:48 -0800
Message-ID: <20060313135048.27b09fba@localhost.localdomain>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
	<1142225063.14909.77.camel@ras.pc.brisbane.lube>
	<1142269090.5242.29.camel@jzny2> <4415B217.30507@trash.net>
	<20060313100421.7df7f9ed@localhost.localdomain>
	<1142286237.17608.7.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Russell Stuart <russell-lartc@stuart.id.au>
In-Reply-To: <1142286237.17608.7.camel@ras.pc.brisbane.lube>
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

On Tue, 14 Mar 2006 07:43:57 +1000
Russell Stuart <russell-lartc@stuart.id.au> wrote:

> On Mon, 2006-03-13 at 10:04 -0800, Stephen Hemminger wrote:
> > The memset fix is in current CVS. I just wasn't going to take the
> > patch that looked at utsname to decide what hash to use.
> 
> Stephen, could you describe your objections to it please?
> 

Because it means that the API for netlink isn't being used properly.
