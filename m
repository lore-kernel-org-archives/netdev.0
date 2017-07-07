From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 RFC 0/13] Remove UDP Fragmentation Offload support
Date: Fri, 7 Jul 2017 13:24:25 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD003590D@AcuExch.aculab.com>
References: <20170707.104326.2165746493532974466.davem@davemloft.net>
 <20170707124531.GA15765@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "willemdebruijn.kernel@gmail.com" <willemdebruijn.kernel@gmail.com>
To: 'Michal Kubecek' <mkubecek@suse.cz>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:51625 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdGGNYp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 09:24:45 -0400
In-Reply-To: <20170707124531.GA15765@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek
> Sent: 07 July 2017 13:46
> On Fri, Jul 07, 2017 at 10:43:26AM +0100, David Miller wrote:
> >
> > This is an RFC patch series, based upon some discussions with
> > various developers, that removes UFO offloading.
> >
> > Very few devices support this operation, it's usefullness is
> > quesitonable at best, and it adds a non-trivial amount of
> > complexity to our data paths.
> 
> My understanding from the communication with the customer whose reports
> resulted in commits acf8dd0a9d0b ("udp: only allow UFO for packets from
> SOCK_DGRAM sockets") and a5cb659bbc1c ("net: account for current skb
> length when deciding about UFO") was that the real benefit from UFO is
> in the case when UFO allows to avoid the need to actually fragment the
> packets. In their case it's when UDP packets are sent via virtio_net
> either between a guest and its host or between two guests on the same
> host.
> ...

Could that be done with a large path-specific mtu?

	David
