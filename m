From: Bradley Peterson <despite@gmail.com>
Subject: Re: BUG in skb_pull with e1000e, PPTP, and L2TP
Date: Mon, 17 Oct 2011 17:30:51 -0500
Message-ID: <CAJuWrdsg3Gz=Z8UYRCoca2zuGgS1EfJjjYrtuo21TQ_oGFEh2g@mail.gmail.com>
References: <CAJuWrdtOru6KSNTxXhhQNEZUTaX5KvyF7macx4RZYxMzcAo0KQ@mail.gmail.com>
	<20111017152531.144b16a1@nehalam.linuxnetplumber.net>
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
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33196 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab1JQWaw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:30:52 -0400
Received: by vws1 with SMTP id 1so3011655vws.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 15:30:52 -0700 (PDT)
In-Reply-To: <20111017152531.144b16a1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2011 at 5:25 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 17 Oct 2011 17:19:53 -0500
> Bradley Peterson <despite@gmail.com> wrote:
>
>> =A0using 3rd
>> party pptp and l2tp modules.
>
> More than likely your 3rd party modules are buggy and
> can't handle all the possible types of skb layout.
> I have seen out of tree code that can't handle non-linear
> skb's. You need to take it up with the those developer.
>

Oh, I should've been more clear -- I am no longer using any 3rd party
modules.  That referred to my previous setup with 2.6.22 (I knew
better than to report that).  This bug is with 2.6.38 using in-tree
modules.

Bradley Peterson
