From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 14:05:25 -0800
Message-ID: <20050331140525.04f9a2b1@dxpl.pdx.osdl.net>
References: <424C6089.1080507@candelatech.com>
	<20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>
	<424C6F82.7030609@candelatech.com>
	<20050331135229.432afff3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050331135229.432afff3.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 13:52:29 -0800
"David S. Miller" <davem@davemloft.net> wrote:

> On Thu, 31 Mar 2005 13:45:38 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> > > 	Adding new ioctl's are very frowned on
> > 
> > Bummer.  I want these as well, makes programatic reading of the information
> > much easier than trying to parse some proc file.  I will look into what it
> > takes to make them compat with 64-bit as DaveM suggested.
> 
> You could extend and use ethtool.  That is what it's there for.

Other possiblity is adding additional attributes onto the device with sysfs.
That is what net/bridge/br_sysfs_if.c does. I'm not claiming it is a pretty
kernel programming model, but the user side API is simpler.
