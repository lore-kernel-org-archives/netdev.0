From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path similar
 to hw-accel
Date: Mon, 04 Apr 2011 23:04:09 +0200
Message-ID: <4D9A3249.6040106@gmail.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com> <4D989100.1090207@gmail.com> <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com> <4D996B30.3080408@gmail.com> <20110404071453.GA2791@psychotron.redhat.com> <4D9A1530.1010102@gmail.com> <m1d3l1eqw8.fsf@fess.ebiederm.org> <4D9A2E74.70105@gmail.com> <BANLkTikpUTSxeHo-DA+=Ta7A7C95_+Kfdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, xiaosuo@gmail.com
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40023 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707Ab1DDVEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 17:04:12 -0400
Received: by wwa36 with SMTP id 36so6936892wwa.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 14:04:11 -0700 (PDT)
In-Reply-To: <BANLkTikpUTSxeHo-DA+=Ta7A7C95_+Kfdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/04/2011 22:50, Jesse Gross a =E9crit :
> On Mon, Apr 4, 2011 at 1:47 PM, Nicolas de Peslo=FCan
> <nicolas.2p.debian@gmail.com>  wrote:
>> Can someone clarify whether hwaccel capable NIC will always untag ta=
gged
>> frames or will only do so if requested at device setup?
>
> It can be changed on the fly by ethtool, similar to other forms of of=
floading.

Thanks Jesse.

So if hwaccell vlan untagging is disabled, what is the current behavior=
? Is the frame delivered=20
untouched (tagged) to ptype_all handlers if no particular vlan device i=
s setup on the parent device?

With Jiri's patch, it would be always untagged, whatever requested by e=
thtool.

Am I right?

	Nicolas.

