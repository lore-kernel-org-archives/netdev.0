From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] [TC/U32] Infrastructure for pretty printing
Date: Mon, 21 Apr 2008 09:58:55 -0400
Message-ID: <1208786335.12249.194.camel@localhost>
References: <1208702964.12249.57.camel@localhost>
	 <480C8006.3060708@trash.net> <1208784237.12249.181.camel@localhost>
	 <480C96D3.5050809@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:5389 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbYDUN7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 09:59:24 -0400
Received: by ik-out-1112.google.com with SMTP id c28so144025ika.5
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 06:59:22 -0700 (PDT)
In-Reply-To: <480C96D3.5050809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-21-04 at 15:29 +0200, Patrick McHardy wrote:

> Something like that. But it used to already work the
> way I described, at least for all parts where I tested
> it so far (IIRC routes/rules/addresses/qdiscs/classes/filters).

ok, missed that - i dont recall ever using it like that. But i will test
and make sure it works. Now i get more of what you are saying with the
env variables.

> Yes, the first part needs to be stripped (filter/qdisc/class/...).
> I usually do something like
> 
> "ip link/route/addr del <paste dump without first word here>".
> 
> Similar for tc.

Ok, just tried it on my laptop; u32 (and maybe the rest of the filters)
doesnt work in this mode. Essentially inputting is of the form
"match u{8,16,32} value mask" and output is of form "match
32bitval/32bitmask"
I think it should be easier to do with cooked mode and i will look into
it.

> It would be nice to dump it in a format that can be piped
> into batch mode without further changes, so it would have
> to insert "add" between "filter" and "protocol".

An additional processing may be needed in the save script.

cheers,
jamal

