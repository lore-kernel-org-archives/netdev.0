From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
	instead of master
Date: Mon, 7 Mar 2011 21:43:57 -0500
Message-ID: <20110308024356.GV11864@gospo.rdu.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com> <20110307224338.GU11864@gospo.rdu.redhat.com> <4D7565BC.4050201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755952Ab1CHCoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:44:10 -0500
Content-Disposition: inline
In-Reply-To: <4D7565BC.4050201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2011 at 12:09:48AM +0100, Nicolas de Peslo=FCan wrote:
>
> After Jiri's last patch series, bond_arp_rcv() is not registered anym=
ore=20
> as a protocol handler on bond0, but directly called from inside=20
> bond_handle_frame(), through bond->recv_probe.
>
> Because bond_handler_frame() is a rx_handler for the slave interfaces=
,=20
> bond_arp_rcv() is now called at the slave level and not a the master=20
> level anymore.
>
> Hence this patch and the reason I thought it should work.
>
> Did you tested this patch with Jiri's previous patches applied before=
?
>

No, I have not tested them yet.  I looked at this problem first as
Jiri's patch did not fix a regression in code that is actually in
net-next right now.

I don't have a problem with the work you and Jiri are doing on this
latest patch series, but the frequency of patch revisions and now
regressions concerns me.

