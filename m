From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] vlan: avoid a synchronize_net when parent
 device goes down
Date: Mon, 09 Mar 2015 15:22:11 -0400 (EDT)
Message-ID: <20150309.152211.2300226482423280727.davem@redhat.com>
References: <1425598621-18083-1-git-send-email-noureddine@arista.com>
	<20150308.222134.544504915277666481.davem@davemloft.net>
	<CAO7SqHB=1+bQyU4Tt-RTkDYAU5GH_536hVfW1HU3jJz8iTySJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: noureddine@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110AbbCITWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 15:22:21 -0400
In-Reply-To: <CAO7SqHB=1+bQyU4Tt-RTkDYAU5GH_536hVfW1HU3jJz8iTySJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@arista.com>
Date: Mon, 9 Mar 2015 12:00:31 -0700

> Thanks for pointing to the right direction. Is there a reason the vlan
> driver was calling
> dev_change_flags instead of dev_close to close the vlan device?

Perhaps dev_close() was not exported at the time the code was written,
I honestly have no idea.
