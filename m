From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Wed, 7 Jul 2004 14:22:16 -0700
Sender: lartc-admin@mailman.ds9a.nl
Message-ID: <20040707142216.7c9763c3@dell_ss3.pdx.osdl.net>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	<20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	<1088824432.1043.271.camel@jzny.localdomain>
	<20040707111055.32ebb25b@dell_ss3.pdx.osdl.net>
	<1089226667.1027.411.camel@jzny.localdomain>
	<20040707135831.4c98dd51@dell_ss3.pdx.osdl.net>
	<1089234699.1026.448.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
	Catalin BOIE <util@deuroconsult.ro>, netdev@oss.sgi.com,
	lartc@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1089234699.1026.448.camel@jzny.localdomain>
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

On 07 Jul 2004 17:11:39 -0400
jamal <hadi@cyberus.ca> wrote:

> On Wed, 2004-07-07 at 16:58, Stephen Hemminger wrote:
> 
> > TBF works but since the sender (on the same local machine) may go over 
> > it's allocation, it will drop packets.
> 
> As should any queue that gets congested.

> > For example, if I use tbf to simulate a slow 33k bits/sec link then 
> > TCP test never
> > completes, it just hangs!  TBF does work for intermediate sizes.
> > 
> > But if I use the pacing simulation it works.
> 
> I am not sure i follow; is this because of the return code from the
> enqueue?

Actually, the problem only occurs if burst is set large (like 2mb).
I think it gets stuck waiting for that much data.

_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
