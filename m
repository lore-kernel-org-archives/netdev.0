From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 06:37:26 +0000
Message-ID: <20090901063726.GA5222@ff.dom.local>
References: <20090901062840.f1c25757.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Lameter <cl@linux-foundation.org>,
	netdev@vger.kernel.org, davem@linux-foundation.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58774 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbZIAGha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 02:37:30 -0400
Received: by bwz19 with SMTP id 19so3286568bwz.37
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 23:37:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090901062840.f1c25757.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31-08-2009 22:58, Mark Smith wrote:
> On Mon, 31 Aug 2009 21:54:49 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Christoph Lameter a =E9crit :
>>> This is with 2.6.31-rc7. If I send icmp then its correctly register=
ed as a
>>> packet by the qdisc layer:
>>>
> <snip>
>> loopback device do bypass qdisc layer for example...
>=20
> On occassion, I'd have found it useful if it didn't. It'd be convenie=
nt
> to test out your qdisc config, or test out applications performance
> behaviour over a simulated WAN via netem, without having to a
> network and two hosts, and all the related miscellaneous setup work.

Probably Eric and you mean something special, but generally a loopback
and some other virtuals bypass qdisc layer only with default qdisc.

Jarek P.
