From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: MPLS for Linux kernel
Date: Wed, 23 Nov 2011 08:09:31 +0100
Message-ID: <CAFdo_mVb4aCcWT8a9pk8Ypt9+GnLqSDDiPOAwOsgWZRcTH_NaQ@mail.gmail.com>
References: <4ECBB2C4.9000505@dti2.net>
	<CAFdo_mUH=21_+xuLqE6tytHmD-QwXb9XXfTzixYFqUcbcLAfWQ@mail.gmail.com>
	<CAFdo_mVdva4=4bJOaXQTNHhD-3h5LSLvERi8D7s-45SdRO5ibA@mail.gmail.com>
	<20111122.164909.156852889818363753.davem@davemloft.net>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:53389 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755406Ab1KWHJg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 02:09:36 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 0222960176
	for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 08:09:35 +0100 (CET)
Received: from mx2.etf.bg.ac.rs ([147.91.14.170])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id Pn1DRwgtP5I1 for <netdev@vger.kernel.org>;
	Wed, 23 Nov 2011 08:09:34 +0100 (CET)
Received: from mail-yw0-f46.google.com (mail-yw0-f46.google.com [209.85.213.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id F1DCD60174
	for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 08:09:33 +0100 (CET)
Received: by ywt32 with SMTP id 32so1052550ywt.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 23:09:32 -0800 (PST)
In-Reply-To: <20111122.164909.156852889818363753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK,
Thanks

2011/11/22 David Miller <davem@davemloft.net>:
> From: Igor Maravi=E6 <igorm@etf.rs>
> Date: Tue, 22 Nov 2011 22:41:44 +0100
>
>> I would like to know what is necesary for MPLS implementation to hav=
e,
>> and to do, so it would be accepted in upstream kernel?
>
> A long and laborious back and forth review process, taking into consi=
deration
> not just the technical details of the patches themselves, but the top=
 level
> and overall design.
>
> That's what it will take.
>
> Taking someone else's work, fixing all the bugs and cleaning them up =
is
> far from sufficient for a feature of this nature. =A0There is natural
> overlap all over and we have to make sure the implementation bits are
> going into the right places.
>
> One issue of constant contention is that people want to add all of th=
eir
> favorite packet filtering and packet mangling into their protocol han=
dling
> code, with all kinds of custom controls and configuration mechanisms.
>
> WE HATE THIS.
>
> We have the packet scheduler classifiers and packet actions for a rea=
son,
> and we want them to used instead of ignored.
>
> We are going through the same thing in the review process for the ope=
nvswitch
> code, which brings up another design question for MPLS, which is whet=
her MPLS
> can be better implemented in terms of openvswitch.
>
> You're in the unfortunate position of submitting a feature that has a
> lot of overlap with many other subsystems, existing code, and feature=
s
> being submitted at the same time. =A0We want as much reuse as possibl=
e,
> and we want it all designed right before it gets integrated.
>
> I frankly don't care very much about MPLS personally, it's such a
> fringe facility. =A0So if people just argue themselves into oblivion =
and
> no forward progress is made, just like last time an MPLS submission
> was attempted, that's also fine with me :-)
>
