From: Maxim Osipov <maxim.osipov@gmail.com>
Subject: Re: [PATCH 4/5] ieee802154: add documentation about our stack
Date: Sat, 6 Jun 2009 11:12:35 +0400
Message-ID: <6097c490906060012s4f1965d1sd29eabab2040f02b@mail.gmail.com>
References: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-2-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-3-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-5-git-send-email-dbaryshkov@gmail.com>
	 <1244207921.23850.17.camel@localhost.localdomain>
	 <bc64b4640906050640n77bddf37u8e549dff72508c2d@mail.gmail.com>
	 <1244211945.23850.53.camel@localhost.localdomain>
Reply-To: maxim@mox.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	davem@davemloft.net, Stephen Rothwell <sfr@canb.auug.org.au>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:56140 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbZFFHMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2009 03:12:35 -0400
In-Reply-To: <1244211945.23850.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 5, 2009 at 6:25 PM, Marcel Holtmann<marcel@holtmann.org> wrote:
>> Hmm. AX.25, AppleTalk, CAN, DecNet, most of other procotols sitting inside
>> Linux kernel do use net_device structure, why should we differ?
>
> Don't know about CAN since I never looked deep enough into it. However
> for the other, they do transport some sort of networking packets over
> it. So my point is as long as I can use ifconfig of ip to set an address
> on these interfaces and route them it makes sense to. Just to reuse
> net_device because it is convenient for a control interface sounds wrong
> to me. The IrDA stuff is one big example of this.
>

ieee802154 does actually transport networking packets. It is
networking and not just another peer-to-peer interface, so I guess it
shall be implemented as a network.

Kind regards,
Maxim
