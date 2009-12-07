From: Gurucharan Shetty <gshetty@riverbed.com>
Subject: Re: [PATCH] ixgbe: allow tx of pre-formatted vlan tagged packets
Date: Mon, 7 Dec 2009 12:02:08 -0800
Message-ID: <1260216128.4226.18.camel@gshetty>
References: <1259961156.4198.163.camel@gshetty>
	 <9929d2390912041345g4557770bh1467db58b8ade572@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arthur Jones <Arthur.Jones@riverbed.com>,
	Gurucharan Shetty <gshetty@riverbed.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.riverbed.com ([208.70.196.45]:13554 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758721AbZLGUCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 15:02:02 -0500
In-Reply-To: <9929d2390912041345g4557770bh1467db58b8ade572@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-04 at 13:45 -0800, Jeff Kirsher wrote:
> On Fri, Dec 4, 2009 at 13:12, Gurucharan Shetty <gshetty@riverbed.com> wrote:
> > ixgbe: allow tx of pre-formatted vlan tagged packets
> >
> > When the 82598 is fed 802.1q packets, it chokes with
> > an error of the form:
> >
> > ixgbe: eth0: ixgbe_tx_csum: partial checksum but proto=81!
> >
> > As the logic there was not smart enough to look into
> > the vlan header to pick out the encapsulated protocol.
> >
> > There are times when we'd like to send these packets
> > out without having to configure a vlan on the interface.
> > Here we check for the vlan tag and allow the packet to
> > go out with the correct hardware checksum.
> >
> > This patch is a clone of a previously submitted patch by
> > Arthur Jones <ajones@riverbed.com> for igb (Commit -
> > fa4a7ef36ec834fee1719636b30d2f28f4cb0166).
> >
> > Signed-off-by: Gurucharan Shetty <gshetty@riverbed.com>
> > Signed-off-by: Arthur Jones <ajones@riverbed.com>
> >
> 
> Thanks, I have added the patch to my queue for testing.  After
> successful testing, I will push to Dave/netdev.
> 
Oops. I messed up with the patch that I sent. It missed a line.
I am re-sending the patch in the next message. Sorry for the
inconvenience.

Thanks,
Gurucharan Shetty

