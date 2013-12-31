From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [GIT] Networking
Date: Tue, 31 Dec 2013 07:56:04 +0200
Message-ID: <CAJZOPZJo1oEkGDp+FiiNT81xs5jwH4uEaBDW8ywP5OAw185UCw@mail.gmail.com>
References: <20131229.230224.1652891996387193020.davem@davemloft.net>
	<CAJZOPZLciJ=X9_h9eqd0KrdkrOT6tKw93wFnmDKY6cQfG_4ZTw@mail.gmail.com>
	<20131230.195209.1342950946997239413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Wei-Chun Chao <weichunc@plumgrid.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:51124 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab3LaF4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 00:56:06 -0500
Received: by mail-pa0-f49.google.com with SMTP id kx10so12337329pab.36
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 21:56:05 -0800 (PST)
In-Reply-To: <20131230.195209.1342950946997239413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 31, 2013 at 2:52 AM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <or.gerlitz@gmail.com>
> Date: Mon, 30 Dec 2013 14:50:09 +0200

>> Just wanted to check with you re this fix which makes hw offloaded
>> vxlan gso traffic from VMs to actually work...
>> http://patchwork.ozlabs.org/patch/303025
>> I would say we really want it for 3.13 and after spending some time
>> there into -stable down to 3.10.y where the offloaded gso was
>> introduced - makes sense?
>
> Alternative ways to fix the problem were being discussed and therefore
> the patch is in "Changes Requested" state, so you shouldn't be
> expecting me to apply it.

Dave, I know there was feedback - yours inputs (to add helper function
and rebase against net)  given here
http://marc.info/?l=linux-netdev&m=138808146909076&w=2 are addressed
in V2 of the patch
http://marc.info/?l=linux-netdev&m=138809223011119&w=2, Stephen had
comments on V1 asking if this can be done in a different manner -- but
I am somehow under the impression that we are aligned on the initial
approach + your feedback addressed, so I missed something along the
way?
