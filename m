From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: 07 Jul 2004 17:11:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089234699.1026.448.camel@jzny.localdomain>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	 <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	 <1088824432.1043.271.camel@jzny.localdomain>
	 <20040707111055.32ebb25b@dell_ss3.pdx.osdl.net>
	 <1089226667.1027.411.camel@jzny.localdomain>
	 <20040707135831.4c98dd51@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Catalin BOIE <util@deuroconsult.ro>,
        netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040707135831.4c98dd51@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-07-07 at 16:58, Stephen Hemminger wrote:

> TBF works but since the sender (on the same local machine) may go over 
> it's allocation, it will drop packets.

As should any queue that gets congested.

> For example, if I use tbf to simulate a slow 33k bits/sec link then 
> TCP test never
> completes, it just hangs!  TBF does work for intermediate sizes.
> 
> But if I use the pacing simulation it works.

I am not sure i follow; is this because of the return code from the
enqueue?

cheers,
jamal
