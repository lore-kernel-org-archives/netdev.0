From: jamal <hadi@cyberus.ca>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
	interfaces
Date: 12 Jan 2004 08:51:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1073915461.1118.342.camel@jzny.localdomain>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com>
	 <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com>
	 <4001C158.6040103@candelatech.com> <4001C72E.8030108@pobox.com>
	 <20040112133816.57993f44.ak@suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, greearb@candelatech.com,
        amir.noam@intel.com, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040112133816.57993f44.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi,
Can you point to specifics that break 64 bit emulation so we can avoid
them?
I have to admit the pf_key interaction is relatively unorthrodox but
looked fine.
What are the things you will perform surgery on?

cheers,
jamal

On Mon, 2004-01-12 at 07:38, Andi Kleen wrote:
> On Sun, 11 Jan 2004 16:59:10 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
> > ioctls are a pain for 32/64-bit emulation layers too.  It seems much 
> > easier to define a netlink protocol family of some sort and communicate 
> > that way.
> 
> Actually that's not true. netlink is far worse for emulation layers when you
> break the protocol. e.g. the current ipsec/pf_key protocol is not compatible
> on x86-64 and it is near impossible to fix it without major surgery.
> With ioctls it would be far easier to fixbecause the infrastructure for emulation
> is already there.
> 
> -Andi
> 
