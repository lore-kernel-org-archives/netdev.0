From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 action/policer question
Date: Mon, 15 Jun 2009 22:07:05 +0200
Message-ID: <20090615200705.GA3724@ami.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com> <20090615145222.GA2767@ami.dom.local> <4A367255.5050604@itcare.pl> <20090615163706.GA9469@ami.dom.local> <20090615164417.GB9469@ami.dom.local> <4A368025.5000902@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:52903 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbZFOUHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 16:07:25 -0400
Received: by bwz9 with SMTP id 9so3600926bwz.37
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 13:07:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A368025.5000902@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 07:08:53PM +0200, Pawe=B3 Staszewski wrote:
=2E..
> But what with ipt -j MARK ?
> Where i can catch this mark ?
> Or i can't catch packet like this, but then for what will be this ipt=
 =20
> action ?
>
>
> Because if i understand correct this action works like iptables -j MA=
RK =20
> in POSTROUTING mangle ?

As I wrote before I don't know these things enough, but it's probably
not exactly like using iptables; I guess it's after POSTROUTING if
used at egress or before PREROUTING if at ingress, and you could easily
check this in case of ingress: it should be visible by all iptables
hooks on it's way. So it's probably mostly useful on ingress, like in
doc examples. In case of egress if it's not redirected anywhere, as
I mentionned before, you could detect it e.g. with fw filter called
after ipt, but I'm not sure it's very useful here.

Jarek P.
