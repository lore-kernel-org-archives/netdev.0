From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Tue, 08 Jan 2013 13:13:14 +0000
Message-ID: <50EC297A02000078000B3BB5@nat28.tlf.novell.com>
References: <50EC099D.6020407@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>,
	<xen-devel@lists.xensource.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: "jianhai luan" <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:45268 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707Ab3AHNNR convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 8 Jan 2013 08:13:17 -0500
In-Reply-To: <50EC099D.6020407@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 08.01.13 at 12:57, jianhai luan <jianhai.luan@oracle.com> wrote:
>    When Xen Dom0's network circumstance changed, DomU
> should be notified in some special condition. For
> example the below circumstance:
>    ping from Guest A to DomU:
>    Guest A --> eth0 - bond0 - xenbr0 --VIF(DOMU)
>                eth1 /
>    when eth0 inactive, and eth1 active.
>    Guest A --> eth0   bond0 - xenbr0 --VIF(DOMU)
>                eth1 /
>    Guest A will don't reach to DomU. After Guest A
>    send ARP request and DomU respond, Guest A will
>    reach DomU. But some more second will be elapsed.
>                eth0   bond0 - xenbr0 --VIF(DOMU)
>    Guest A --> eth1/

Isn't a change to the availability of the bonds supposed to be
transparent to Guest A _and_ DomU? I.e. aren't you trying to fix
an eventual problem here in the wrong place?

> If Xen netback watch the network change, will notify
> DomU by change it own status. So netfront will watch
> netback's change, and DomU send ARP initiative.

Your patch is, at least according to what I see, completely
unusable - line breaks dropped, line order reversed, and
(guessing) some UTF-16/UCS-2 characters inserted at the top.
Please attach patches as plain ASCII.

Jan
