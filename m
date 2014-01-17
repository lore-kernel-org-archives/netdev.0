From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next 3/3] virtio-net: Add accelerated RFS support
Date: Fri, 17 Jan 2014 17:20:08 +0000
Message-ID: <1389979208.27141.11.camel@bwh-desktop.uk.level5networks.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	 <1389795654-28381-4-git-send-email-zwu.kernel@gmail.com>
	 <1389907887.11912.87.camel@bwh-desktop.uk.level5networks.com>
	 <CAEH94LjHcxkXLvs6AMNop_yzKG0zaT2mAgsAb21i+RtMbkXbmQ@mail.gmail.com>
	 <1389914188.11912.146.camel@bwh-desktop.uk.level5networks.com>
	 <CAEH94LgKJ0qThGHS-hqXsYKqOe+ns2pRi-wfZy=af1RMejOZ5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43760 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbaAQRUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 12:20:14 -0500
In-Reply-To: <CAEH94LgKJ0qThGHS-hqXsYKqOe+ns2pRi-wfZy=af1RMejOZ5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-18 at 00:54 +0800, Zhi Yong Wu wrote:
> On Fri, Jan 17, 2014 at 7:16 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
[...]
> > However, to take advantage of ARFS on a physical net driver, it would be
> > necessary to send a control request for part 2.
> aRFS on a physical net driver? What is this physical net driver? I
> thought that in order to enable aRFS, guest virtio_net driver should
> send a control request to its emulated virtio_net NIC.
[...]

If the backend is connected to a macvlan device on top of a physical net
device that supports ARFS, then there is further potential for improving
performance by steering to the best physical RX queue and CPU as well as
the best virtio_net RX queue and vCPU.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
