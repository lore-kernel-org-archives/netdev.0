From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] net/bridge/br_if.c: fix possible use-after-free in port_carrier_check()
Date: Wed, 21 Feb 2007 10:29:36 +0100
Message-ID: <20070221092936.GA2311@ff.dom.local>
References: <20070220221941.GA707@tv-sign.ru> <20070220162434.72d3ad7b@freekitty> <20070221082345.GB1662@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@tv-sign.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S\. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965370AbXBUJ0L@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070221082345.GB1662@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 21, 2007 at 09:23:45AM +0100, Jarek Poplawski wrote:
...
> I have known issues with RCU, but dare to disagree here.
> It's done during call_rcu, so anything RCU friendly shouldn't
> see this at the moment at all. It could be needed for those
> with refcounting - than it should be checked, if there is
> anything more than port_carrier_check.

Sorry for this than-ing!
(It's my next favorite issue after RCU.)

Jarek P.
