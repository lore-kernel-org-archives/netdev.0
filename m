From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Fri, 26 Feb 2010 10:49:46 -0800
Message-ID: <20100226104946.4168e378@nehalam>
References: <20100226165104.GB5364@lenovo>
	<4B88076F.8030302@openvz.org>
	<20100226100102.0d52c6e9@nehalam>
	<20100226.100800.116618587.davem@davemloft.net>
	<20100226103003.097c39ec@nehalam>
	<4B8815AE.1090909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xemul@openvz.org,
	gorcunov@gmail.com, bridge@linux-foundation.org,
	netdev@vger.kernel.org, den@openvz.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33605 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965631Ab0BZSt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 13:49:59 -0500
In-Reply-To: <4B8815AE.1090909@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2010 10:40:46 -0800
Ben Greear <greearb@candelatech.com> wrote:

> On 02/26/2010 10:30 AM, Stephen Hemminger wrote:
> > On Fri, 26 Feb 2010 10:08:00 -0800 (PST)
> > David Miller<davem@davemloft.net>  wrote:
> >
> >> From: Stephen Hemminger<shemminger@linux-foundation.org>
> >> Date: Fri, 26 Feb 2010 10:01:02 -0800
> >>
> >>> TCP connections are never really bound to device. TCP routing is
> >>> flexible; if packets can get through, it doesn't care.
> >>
> >> I think he might be talking about SO_BINDTODEVICE
> >
> > What application does that with TCP?
> 
> I use it..helps with using multiple interfaces on the same system,
> especially when sending-to-self.
> 

That is a special case which is not related to the discussion.
We are talking about being able to setup a bridge and migrate the
associated state from the ethernet device to the bridge.


