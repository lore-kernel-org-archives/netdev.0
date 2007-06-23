From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS
 autoconfiguration
Date: Fri, 22 Jun 2007 22:12:29 -0700 (PDT)
Message-ID: <20070622.221229.125566330.davem@davemloft.net>
References: <467C74BA.9060809@simon.arlott.org.uk>
	<OFB5D50B53.A24A00A2-ON88257303.0017FE53-88257303.0018AD5D@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, cscott@laptop.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59804
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751299AbXFWFMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 01:12:12 -0400
In-Reply-To: <OFB5D50B53.A24A00A2-ON88257303.0017FE53-88257303.0018AD5D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Fri, 22 Jun 2007 21:30:05 -0700

> netdev-owner@vger.kernel.org wrote on 06/22/2007 06:17:46 PM:
> 
> > On 23/06/07 02:04, David Stevens wrote:
> > >         Why not make the application that writes resolv.conf
> > > also listen on a raw ICMPv6 socket? I don't believe you'd need
> > > any kernel changes, then, and it seems pretty simple and
> > > straightforward.
> > 
> > Because then it requires yet another network daemon, RA in 
> > the kernel means there's no need for one to manage adding 
> > auto-configured IP addresses... what's wrong with doing the 
> > same for DNS?
> 
>         It's not yet another one, since you have to run something
> to get it in resolv.conf, anyway. That seems much better to me
> than having the kernel track data that can only be used at the
> application layer. The app itself looks like it'd be really simple.
>         Auto-configured addresses are used by the kernel. It has to
> have those addresses. But the kernel doesn't do DNS look-ups, or
> write resolv.conf; that's the difference, for me.

I totally agree with David, this stuff definitely does not belong
in the kernel.
