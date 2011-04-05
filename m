From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Tue, 5 Apr 2011 09:26:22 +0200
Message-ID: <20110405072621.GC3640@psychotron.lan>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com>
 <4D989100.1090207@gmail.com>
 <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com>
 <4D996B30.3080408@gmail.com>
 <20110404071453.GA2791@psychotron.redhat.com>
 <4D9A1530.1010102@gmail.com>
 <m1d3l1eqw8.fsf@fess.ebiederm.org>
 <4D9A2E74.70105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Gross <jesse@kernel.org>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, xiaosuo@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34218 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141Ab1DEH1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 03:27:09 -0400
Content-Disposition: inline
In-Reply-To: <4D9A2E74.70105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 04, 2011 at 10:47:48PM CEST, nicolas.2p.debian@gmail.com wrote=
:
>Le 04/04/2011 21:51, Eric W. Biederman a =E9crit :
>
>>
>>__netif_receive_skb is actually late for untagging.  eth_type_trans
>>would be better but not path of control into __netif_receive_skb
>>actually calls eth_type_trans.
>
>Because vlan may nest, we need to keep some sort of frame untagging in=
side __netif_receive_skb.

You are correct here. It needs to stay inside __netif_receive_skb
