From: jamal <hadi@cyberus.ca>
Subject: Re: multiple unicast mac address (was Re: netdev_ops retraction)
Date: 03 Aug 2003 15:06:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1059937567.1102.77.camel@jzny.localdomain>
References: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk>
	 <2147483647.1059659359@fozzy.rossfell.co.uk> <3F292B38.4070508@pobox.com>
	 <2147483647.1059667766@fozzy.rossfell.co.uk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Payne <rickp@rossfell.co.uk>
In-Reply-To: <2147483647.1059667766@fozzy.rossfell.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Last discussion that happened:

http://marc.theaimsgroup.com/?t=104163060100001&r=1&w=2

cheers,
jamal


On Thu, 2003-07-31 at 11:09, Rick Payne wrote:
> --On Thursday, July 31, 2003 10:44 am -0400 Jeff Garzik <jgarzik@pobox.com> 
> wrote:
> 
> > Hardware that filters N MAC addresses (unicast filtering) doesn't have a
> > terribly standard interface, and the unicast filter must be adjusted at
> 
> Indeed but where its possible to support it, it can be - and those cards 
> will be specified by those who need it (for HA, VRRP etc).
> 
> > different times on different hardware.  Also, chip bugs lead one to think
> > unicast filtering will work where it doesn't.  Also, chip limits for some
> > of the more popular chips are unknown.  Also, the need for this feature
> > is very uncommon, and can be achieved in other ways.
> 
> As I said - promiscuous mode and filtering on the receive side - which is 
> what you have to resort to anyway for those cards that don't support it.
> 
> Alternatively, its just another patch people need to add to make things do 
> what they want - just like the ARP patch.
> 
> Rick
> 
> 
