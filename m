From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Tue, 5 Apr 2011 09:25:00 +0200
Message-ID: <20110405072459.GB3640@psychotron.lan>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com>
 <4D989100.1090207@gmail.com>
 <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com>
 <4D996B30.3080408@gmail.com>
 <20110404071453.GA2791@psychotron.redhat.com>
 <4D9A1530.1010102@gmail.com>
 <m1d3l1eqw8.fsf@fess.ebiederm.org>
 <4D9A2E74.70105@gmail.com>
 <BANLkTikpUTSxeHo-DA+=Ta7A7C95_+Kfdg@mail.gmail.com>
 <4D9A3249.6040106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1894 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920Ab1DEHZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 03:25:46 -0400
Content-Disposition: inline
In-Reply-To: <4D9A3249.6040106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 04, 2011 at 11:04:09PM CEST, nicolas.2p.debian@gmail.com wrote=
:
>Le 04/04/2011 22:50, Jesse Gross a =E9crit :
>>On Mon, Apr 4, 2011 at 1:47 PM, Nicolas de Peslo=FCan
>><nicolas.2p.debian@gmail.com>  wrote:
>>>Can someone clarify whether hwaccel capable NIC will always untag ta=
gged
>>>frames or will only do so if requested at device setup?
>>
>>It can be changed on the fly by ethtool, similar to other forms of of=
floading.
>
>Thanks Jesse.
>
>So if hwaccell vlan untagging is disabled, what is the current
>behavior? Is the frame delivered untouched (tagged) to ptype_all
>handlers if no particular vlan device is setup on the parent device?

Even if vlan device is setup on the parent device.

>
>With Jiri's patch, it would be always untagged, whatever requested by =
ethtool.

Correct. That's more or less purpose of the patch.

>
>Am I right?
>
>	Nicolas.
>
