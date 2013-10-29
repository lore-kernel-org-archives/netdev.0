From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Bug 64011] New: Link-local addresses are used to go outside instead of assigned IPv6 routable address
Date: Tue, 29 Oct 2013 20:36:24 +0100
Message-ID: <20131029193624.GB20147@order.stressinduktion.org>
References: <bug-64011-16487@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: luzemario@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36931 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3J2Tg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 15:36:26 -0400
Content-Disposition: inline
In-Reply-To: <bug-64011-16487@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Tue, Oct 29, 2013 at 01:36:37PM +0000, bugzilla-daemon@bugzilla.kernel.org wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=64011
> 
>             Bug ID: 64011
>            Summary: Link-local addresses are used to go outside instead of
>                     assigned IPv6 routable address
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.11.6-200 and earlier
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV6
>           Assignee: yoshfuji@linux-ipv6.org
>           Reporter: luzemario@gmail.com
>         Regression: No
> 
> Created attachment 112651
>   --> https://bugzilla.kernel.org/attachment.cgi?id=112651&action=edit
> pfSense screenshot of blocked link-local requests to outside
> 
> Sometimes kernel tries to estabilish a IPv6 connection to external global
> routable addresses using [FE80::] link-local addresses, instead of using the
> learned DHCPv6 global-unicast address.
> 
> In the attached screenshot, the machine got an IPv6 address in the
> [2001:1291:200::] range, and was correctly configured.
> 
> Since link-local should not traverse network segments, I am getting lots of
> events in my firewall from several kernel versions of different distros (see
> attachment).
> 
> At the time when the kernel attempts to use the link-local address, there is a
> small delay (around 1s) to open IPv6 pages. It appears kernel tries to reach a
> remote machine using link-local address. When it fails, the kernel uses the
> assigned global routable address.
> 
> This issue was seen on several major distros, as Fedora, Ubuntu, Mageia, etc.
> yet on the distro's later updates.

Could you provide ip -6 a l, ip -6 r l, ip -6 n l and a copy of /proc/net/ipv6_route
(please check that the lines are not broken up)? The configuration of the
router advertisment daemon on your gateway would be interesting, too.

Thanks,

  Hannes
