From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: 07 Jul 2004 14:44:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089225886.1022.383.camel@jzny.localdomain>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	 <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	 <1088824432.1043.271.camel@jzny.localdomain>
	 <20040706090906.4ff6fb73@dell_ss3.pdx.osdl.net>
	 <1089164179.1039.26.camel@jzny.localdomain>
	 <Pine.LNX.4.60.0407070957070.2496@hosting.rdsbv.ro>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Catalin BOIE <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.60.0407070957070.2496@hosting.rdsbv.ro>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-07-07 at 03:01, Catalin BOIE wrote:
> I expect that duplicates of packet will not going to sch_netem, right?
> I'm asking because I have a pactch pending.

I dont think that should stop you from adding the feature. 
To answer your question, yes, duplicates can be sent to that qdisc
using the tc extensions.

> 
> I suggest to keep duplication because:
> 1. Adds 5-10 lines of code and no complexity
> 2. It's very easy to use it attached directly to a device.

Go ahead. The tc extension creation of duplicates can be used with
other qdiscs as well.

cheers,
jamal
