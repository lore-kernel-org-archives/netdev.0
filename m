From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH v3 1/2] Implement IP_UNICAST_IF socket option.
Date: Mon, 6 Feb 2012 12:35:27 -0700
Message-ID: <CAEU2+vrvKS8e0hjkZG0j_Ukm_Fq3KJ9NnSz+Yb1R3vQnn7-vcQ@mail.gmail.com>
References: <62162DF05402B341B3DB59932A1FA992B5B5CA0154@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:45888 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754277Ab2BFTf3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 14:35:29 -0500
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q16JZREC006611
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 6 Feb 2012 12:35:28 -0700
Received: by vbjk17 with SMTP id k17so4112451vbj.19
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 11:35:27 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5CA0154@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2012 at 12:00 PM, Shawn Lu <shawn.lu@ericsson.com> wrote=
:
>On 2/6/12, Erich E. Hoover <ehoover@mines.edu> wrote:
>> ...
>> +             if (sk->sk_bound_dev_if && ifindex !=3D sk->sk_bound_d=
ev_if)
> If I understand right,=A0 when sk->sk_bound_dev_if !=3D0 ,=A0 sk->sk_=
bound_dev_if
> will be used instead. Then why bother to set outif_index.
> Here.

It seems to me that if the socket is already bound to an interface
(other than intended interface) then it makes sense to fail to set the
option, since it will clearly not work under this circumstance.  I may
be misunderstanding you though.

Erich Hoover
ehoover@mines.edu
