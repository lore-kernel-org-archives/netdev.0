From: Jesse Gross <jesse@nicira.com>
Subject: Re: sky2, vlan and nat/masquerading
Date: Fri, 11 Mar 2011 16:39:02 -0800
Message-ID: <AANLkTi=AJJA0d0=CFuS66=+O6b80Ejj0w3NfKQ+OWzsK@mail.gmail.com>
References: <20110309181522.61ca1cc7@leda.vpn.lugor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Christian Hesse <mail@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:43599 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530Ab1CLAjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 19:39:03 -0500
Received: by vxi39 with SMTP id 39so3107103vxi.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 16:39:02 -0800 (PST)
In-Reply-To: <20110309181522.61ca1cc7@leda.vpn.lugor.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 9, 2011 at 9:15 AM, Christian Hesse <mail@eworm.de> wrote:
> Hello everybody,
>
> I have a Samsung NF310, running kernel 2.6.37.3 with a patch to make my
> ethernet controller work for vlans. It was discussed with the subject "sky2:
> convert to new VLAN model (v0.2)" and made it to to kernel tree with commit
> 86aa77854f47ab6f5f9c687507af1f57d2b89004.

Does that commit actually change the behavior that you are seeing?  It
shouldn't be necessary for correct functionality.  Do you know if this
worked at some point in the past?

> However it does not work properly, here are the details:
>
> * Switch with one trunk port and several port in corresponding vlan ports
> * Host connected to one of the vlan ports
> * Samsung Netbook (see above) connected to the trunk port.
>
> I get an IP address 192.168.x.x/24 via DHCP on interface connected to vlan 1.
> The interface connected to vlan 2 has 172.16.0.1/24 and serves addresses via
> DHCP. The system is set up to masquerade from 172.16.0.1/24.
>
> I can access my netbook from the host in vlan 2, however I can not access
> anything behind. The packets contain a broken vlan tag and the host does not
> recognize them.

When you say "the host does not recognize them", what host do you
mean?  This is a different host on vlan 1?

> I've attached a tcpdump log. Please take a look at the icmp echo request and
> reply packets, especially the last one.

What do you mean by broken?  I only see one tag in the trace, which is
on the packet originating from 192.168.100.3 and it has a vid of 0.

Where was this trace captured?
