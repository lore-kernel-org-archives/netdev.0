From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports sg dma
Date: Thu, 1 Aug 2013 10:04:47 +0800
Message-ID: <CACVXFVP_tJeaFA1NCVAS7OGv3267C8YZ-eeUXzj80y-o_1CkbA@mail.gmail.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	<1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	<20130731124707.GA30635@kroah.com>
	<CACVXFVNk+h7kBWTFT2NiGy+2F6LPatda3oL9+uuaQnT-u5J8wg@mail.gmail.com>
	<1375279366.14846.1.camel@linux-fkkt.site>
	<1375283711.10515.104.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum@suse.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37435 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335Ab3HACEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 22:04:50 -0400
In-Reply-To: <1375283711.10515.104.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 11:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-07-31 at 16:02 +0200, Oliver Neukum wrote:
>
> Hmm, I would rather make sure SG is really supported before adding TSO
> support.
>
> TCP stack can build skb with fragments of any size, not multiple
> of 512 or 1024 bytes.

Now Sarah Sharp(xHCD maintainer) has Acked patch 2/4, and confirmed
SG is supported on xHCD, so I appreciate that you network guys may
review the network related changes in patch 3/4 and 4/4, then we
can move on, :-)


Thanks,
--
Ming Lei
