From: jamal <hadi@cyberus.ca>
Subject: Re: VLAN patches
Date: Sun, 6 Oct 2002 18:47:50 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210061839210.1861-100000@shell.cyberus.ca>
References: <20021005.220549.15266753.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <greearb@candelatech.com>, <Bjorn.Andersson@ebc.ericsson.se>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20021005.220549.15266753.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 5 Oct 2002, David S. Miller wrote:

> I think we should, please submit a patch which denies it on
> both config and delete.
>

A packet with VLANid 0 and an 802.1p tag > 0 is legal. I
think its known as a "priority tagged" packet (not 100% sure
about the term). Therefore VLANid 0 MUST be accepted and ability to send
it should be there.
BTW, what about VLANid 0xFFF?

cheers,
jamal
