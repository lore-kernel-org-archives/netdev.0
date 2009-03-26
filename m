From: Dan Williams <dcbw@redhat.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Thu, 26 Mar 2009 16:17:42 -0400
Message-ID: <1238098662.3254.10.camel@localhost.localdomain>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
	 <20090324.155756.214460004.davem@davemloft.net>
	 <49CA927B.9080709@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Matt_Domsch@dell.com,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <49CA927B.9080709@nortel.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-03-25 at 14:22 -0600, Chris Friesen wrote:
> David Miller wrote:
> > From: Matt Domsch <Matt_Domsch@dell.com>
> > Date: Tue, 24 Mar 2009 10:46:17 -0500
> > 
> >> Problem: Users expect on-motherboard NICs to be named eth0..ethN.
> >> This can be difficult to achieve.
> > 
> > I learned a long time ago that eth0 et al. have zero meaning.
> > 
> > If the system firmware folks gave us topology information with respect
> > to these things, we could export something that tools such as
> > NetworkManager, iproute2, etc. could use.
> 
> <snip>
> 
> > I guess it's easier to spew about MAC addresses and other
> > irrelevant topics than try to solve this problem properly. :-)
> 
> What about things like USB network adapters where the topology is not 
> fixed?  Presumably we would want to use some sort of unique identifier, 
> and the MAC comes to mind.  Of course, then you run into the problem of 
> how to deal with duplicate MACs.

USB devices do have a serial number field in the descriptors, but that
only sometimes gets populated with sensible values.  More often than not
it's just zeros.  But worth checking if the MAC isn't set yet.

Dan


