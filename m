From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Mon, 25 Jun 2007 13:08:57 -0400
Message-ID: <1182791337.5184.49.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182252616.21013.12.camel@johannes.berg>
	 <1182270006.4968.62.camel@localhost>
	 <1182338744.3714.59.camel@johannes.berg>
	 <1182440840.5017.40.camel@localhost>
	 <1182506947.21939.89.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	lenb@kernel.org, Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:33363 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbXFYRJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 13:09:01 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1003331wra
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 10:09:00 -0700 (PDT)
In-Reply-To: <1182506947.21939.89.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-22-06 at 12:09 +0200, Johannes Berg wrote:

> Why do you think that would be hard? It'd basically just mean replacing
> the netlink_capable(sock, NL_NONROOT_RECV) calls with a call that
> actually tests depending on the group(s) it wants.

I think it could be done. You will need to have root maybe initially set
such permissions etc - but it may be overkill.

> Yeah, sounds reasonable, you could ask the controller for which groups
> are attached to a family and then get the IDs for those groups by name.

Yes, we would need a newer api to do it right. But it could be done if
you register for multi groups.

cheers,
jamal

PS:- I just noticed Thomas wasnt CCed.


