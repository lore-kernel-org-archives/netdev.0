From: jamal <hadi@cyberus.ca>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
	master'ssettings toslaves
Date: 12 Aug 2003 11:05:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060700754.1065.34.camel@jzny.localdomain>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
	 <200308111720.38472.shmulik.hen@intel.com>
	 <1060612481.1034.15.camel@jzny.localdomain>
	 <200308111925.38278.shmulik.hen@intel.com> <3F37C7C3.7070807@pobox.com>
	 <3F37D2ED.B4B9223C@thalesatm.com> <3F37D5BF.8000702@pobox.com>
	 <3F3889C7.1B4EC2BE@thalesatm.com>
	 <1060693157.1027.87.camel@jzny.localdomain>
	 <20030812060845.0e0ba2e8.davem@redhat.com>
	 <3F38F569.C1EC7769@thalesatm.com>
	 <1060698412.1063.7.camel@jzny.localdomain>
	 <3F38FB78.4536593A@thalesatm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, jgarzik@pobox.com,
   shmulik.hen@intel.com, bonding-devel@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Laurent DENIEL <laurent.deniel@thalesatm.com>
In-Reply-To: <3F38FB78.4536593A@thalesatm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-08-12 at 10:36, Laurent DENIEL wrote:


> Hardware / software watchdogs are great but do not necessarily 
> solve all problems especially where timing constraints are important.

I think we are going on a tangent; i could ask you next why you think it
is less likely to have bugs in the kernel than in user space. Please
dont respond because we'll get into long circular debates.

> I prefer to rely on the timing of the bonding kernel code to switch
> NIC in milli seconds that to wait seconds or minutes that a user space
> daemon have the hand to handle the problem (and yes, I am aware of 
> real time class scheduling and so on, but you say don't trust the 
> software, and I agree so I prefer a direct kernel hang than nothing 
> or something too late (software watchdog will not help in that case).

I dont think we have any disagreements that minimalistic kernel policy
should stay. I am not suggesting to move what the _original_ bonding
driver did out of the kernel - so i dont think there are issues with
"waiting for seconds". Are you basing this on experience?

The key is this: We should start looking at bonding as an enabler for 
availabilty not as _the solution_. Bonding provides link availability
for single hops;
 
cheers,
jamal
