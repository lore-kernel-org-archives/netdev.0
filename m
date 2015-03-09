From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH net-next] vlan: avoid a synchronize_net when parent device
 goes down
Date: Mon, 9 Mar 2015 12:00:31 -0700
Message-ID: <CAO7SqHB=1+bQyU4Tt-RTkDYAU5GH_536hVfW1HU3jJz8iTySJQ@mail.gmail.com>
References: <1425598621-18083-1-git-send-email-noureddine@arista.com>
	<20150308.222134.544504915277666481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34609 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbbCITAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 15:00:32 -0400
Received: by pdno5 with SMTP id o5so22796693pdn.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 12:00:31 -0700 (PDT)
In-Reply-To: <20150308.222134.544504915277666481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks for pointing to the right direction. Is there a reason the vlan
driver was calling
dev_change_flags instead of dev_close to close the vlan device?

Thanks,

Salam


>
> Please let's implement this properly.  VLAN is not the only case
> that would benefit from something like this.
>
