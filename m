From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IFB and bridges
Date: Sun, 11 Dec 2011 23:00:59 +0100
Message-ID: <1323640859.2576.5.camel@edumazet-laptop>
References: <20a26951-0f6c-46f4-9acd-85d0e60cd114@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62461 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439Ab1LKWBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 17:01:04 -0500
Received: by bkcjm19 with SMTP id jm19so794506bkc.19
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2011 14:01:02 -0800 (PST)
In-Reply-To: <20a26951-0f6c-46f4-9acd-85d0e60cd114@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 11 d=C3=A9cembre 2011 =C3=A0 17:38 -0500, John A. Sullivan =
III a >=20
> I know IFB is often used for ingress but I wasn't really thinking of
> ingress filtering.  Let's say I have a 12 port Linux switch.  If any
> of the ports become backlogged, I want them to prioritize time
> sensitive traffic so I implement traffic shaping but I don't want to
> have to define my qdiscs, classes, and filters 12 times over if they
> are all the same.  So I would direct each port to an IFB (not sure if
> that's intolerable overhead), have a single set of qdiscs, classes,
> and filters, and, once those are applied, the packet arrives back on
> the same interface and proceeds assuming if has not been dropped or
> delayed. - John

Really ? How are you going to shape a single IFB device, if you really
have independant 12 ports. (Its a switch, not a hub after all)

A script can define your qdiscs/classes/filters hundred times, or one
thousand times, and writing such a script is far more easier than setup
IFB.
