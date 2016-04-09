From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Sat, 9 Apr 2016 14:27:59 +0200
Message-ID: <20160409142759.25d8464a@redhat.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
	<CALx6S34m8cVNgvuGp845bicixodfavH9cj-rARSwwEAvFCjd7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes@sipsolutions.net>,
	eranlinuxmellanox@gmail.com, Lorenzo Colitti <lorenzo@google.com>,
	brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753659AbcDIM2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2016 08:28:08 -0400
In-Reply-To: <CALx6S34m8cVNgvuGp845bicixodfavH9cj-rARSwwEAvFCjd7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Apr 2016 08:17:04 -0300
Tom Herbert <tom@herbertland.com> wrote:

> One other API issue is how to deal with encapsulation. In this case a
> header may be prepended to the packet, I assume there are BPF helper
> functions and we don't need to return a new length or start?

That reminds me.  Do the BPF program need to know the head-room, then?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
