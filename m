From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 06:44:34 -0800
Message-ID: <1447253074.17135.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	 <20151110233448.GA8646@electric-eye.fr.zoreil.com>
	 <yw1xio59pdw6.fsf@unicorn.mansr.com>
	 <20151110.211121.422193831316296487.davem@davemloft.net>
	 <yw1xa8qkpvy3.fsf@unicorn.mansr.com> <yw1x6118pu0o.fsf@unicorn.mansr.com>
	 <1447248595.17135.98.camel@edumazet-glaptop2.roam.corp.google.com>
	 <yw1x1tbwpry3.fsf@unicorn.mansr.com>
	 <1447250961.17135.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <yw1xsi4coc58.fsf@unicorn.mansr.com> <yw1xoaf0ob86.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xoaf0ob86.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-11-11 at 14:35 +0000, M=C3=A5ns Rullg=C3=A5rd wrote:

> It seems the on-chip interconnect is limiting memory bandwidth availa=
ble
> to the Ethernet DMA.  If I increase the limits, I get 800 Mbps over T=
CP
> and 850 Mbps over UDP with the driver posted here, the TCP case being
> CPU bound in csum_partial_copy_from_user.

Ah right, NIC has no TX checksum offload :(
