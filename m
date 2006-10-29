From: Denis Vlasenko <vda.linux@googlemail.com>
Subject: Re: 2.6.18 forcedeth GSO panic on send
Date: Sun, 29 Oct 2006 22:57:54 +0100
Message-ID: <200610292257.54655.vda.linux@googlemail.com>
References: <200610270117.57877.vda.linux@googlemail.com> <20061029141029.GA5084@gondor.apana.org.au> <200610292245.40702.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:39811 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030242AbWJ2U75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 15:59:57 -0500
Received: by ug-out-1314.google.com with SMTP id 32so1012569ugm
        for <netdev@vger.kernel.org>; Sun, 29 Oct 2006 12:59:56 -0800 (PST)
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <200610292245.40702.vda.linux@googlemail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 29 October 2006 22:45, Denis Vlasenko wrote:
> On Sunday 29 October 2006 15:10, Herbert Xu wrote:
> > On Sun, Oct 29, 2006 at 01:55:56PM +0100, Denis Vlasenko wrote:
> > > With "echo 1 >/proc/sys/kernel/panic_on_oops" I've got
> > > what you're requested. See screenshot:
> > > 
> > > http://busybox.net/~vda/gso_panic/forcedeth_gso_panic2.jpg
> > 
> > Thanks!
> > 
> > Please let me know if this patch fixes it:
> > 
> > [NET]: Fix segmentation of linear packets
> 
> Okay, will test now.

Patch seems to fix the issue. Thanks.

> setting on it? Also what is the ethtool -k setting on the
> interface where you expect ssh to go out?

# ethtool -k if
Offload parameters for if:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
--
vda
