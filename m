From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: BUG in skb_pull with e1000e, PPTP, and L2TP
Date: Mon, 17 Oct 2011 15:25:31 -0700
Message-ID: <20111017152531.144b16a1@nehalam.linuxnetplumber.net>
References: <CAJuWrdtOru6KSNTxXhhQNEZUTaX5KvyF7macx4RZYxMzcAo0KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Bradley Peterson <despite@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45240 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134Ab1JQWZe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:25:34 -0400
In-Reply-To: <CAJuWrdtOru6KSNTxXhhQNEZUTaX5KvyF7macx4RZYxMzcAo0KQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2011 17:19:53 -0500
Bradley Peterson <despite@gmail.com> wrote:

>  using 3rd
> party pptp and l2tp modules.=A0

More than likely your 3rd party modules are buggy and
can't handle all the possible types of skb layout.=20
I have seen out of tree code that can't handle non-linear
skb's. You need to take it up with the those developer.
