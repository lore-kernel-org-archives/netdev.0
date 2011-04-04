From: Jesse Gross <jesse@kernel.org>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path similar
 to hw-accel
Date: Mon, 4 Apr 2011 13:50:37 -0700
Message-ID: <BANLkTikpUTSxeHo-DA+=Ta7A7C95_+Kfdg@mail.gmail.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com>
 <4D989100.1090207@gmail.com> <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com>
 <4D996B30.3080408@gmail.com> <20110404071453.GA2791@psychotron.redhat.com>
 <4D9A1530.1010102@gmail.com> <m1d3l1eqw8.fsf@fess.ebiederm.org> <4D9A2E74.70105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, xiaosuo@gmail.com
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48849 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755502Ab1DDUu6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:50:58 -0400
Received: by vxi39 with SMTP id 39so4477923vxi.19
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 13:50:57 -0700 (PDT)
In-Reply-To: <4D9A2E74.70105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 4, 2011 at 1:47 PM, Nicolas de Peslo=FCan
<nicolas.2p.debian@gmail.com> wrote:
> Can someone clarify whether hwaccel capable NIC will always untag tag=
ged
> frames or will only do so if requested at device setup?

It can be changed on the fly by ethtool, similar to other forms of offl=
oading.
