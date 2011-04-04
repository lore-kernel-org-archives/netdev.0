From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path similar
 to hw-accel
Date: Mon, 04 Apr 2011 22:51:25 +0200
Message-ID: <4D9A2F4D.1000100@gmail.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com> <4D989100.1090207@gmail.com> <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com> <4D996B30.3080408@gmail.com> <20110404071453.GA2791@psychotron.redhat.com> <4D9A1530.1010102@gmail.com> <20110404203002.GB3657@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@kernel.org>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, xiaosuo@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46283 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455Ab1DDUv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:51:28 -0400
Received: by wwa36 with SMTP id 36so6925758wwa.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 13:51:27 -0700 (PDT)
In-Reply-To: <20110404203002.GB3657@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/04/2011 22:30, Jiri Pirko a =E9crit :
> Mon, Apr 04, 2011 at 09:00:00PM CEST, nicolas.2p.debian@gmail.com wro=
te:
>> Le 04/04/2011 09:14, Jiri Pirko a =E9crit :
<snip>
>> So you want to move vlan_do_receive into an rx_handler, but want
>> untagging to stay hard-coded at the beginning of __netif_receive_skb=
=2E
>> I don't think I understand the rational behind that.
>
> vlan_hwaccel_do_receive/vlan_do_receive could be converted to
> rx_handler, not untagging.

Why do you consider untagging cannot be converted to rx_handler?
