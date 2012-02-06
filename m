From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH v3 1/2] Implement IP_UNICAST_IF socket option.
Date: Mon, 6 Feb 2012 15:14:56 -0700
Message-ID: <CAEU2+vqsB=uUTyhuQ1-52kfFi82R25r2ydexjdVC0s1omUt7qQ@mail.gmail.com>
References: <62162DF05402B341B3DB59932A1FA992B5B5CA0154@EUSAACMS0702.eamcs.ericsson.se>
	<CAEU2+vrvKS8e0hjkZG0j_Ukm_Fq3KJ9NnSz+Yb1R3vQnn7-vcQ@mail.gmail.com>
	<62162DF05402B341B3DB59932A1FA992B5B5CA01B7@EUSAACMS0702.eamcs.ericsson.se>
	<CAEU2+vrS_HmpUmcSkrsGq0RYZxynYmXrY_Pm9ESa=280kEqSgg@mail.gmail.com>
	<62162DF05402B341B3DB59932A1FA992B5B5CA0245@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:42620 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755705Ab2BFWO5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 17:14:57 -0500
Received: from mail-vx0-f174.google.com (mail-vx0-f174.google.com [209.85.220.174])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q16MEuHg024904
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 6 Feb 2012 15:14:56 -0700
Received: by vcge1 with SMTP id e1so4240212vcg.19
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 14:14:56 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5CA0245@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2012 at 1:30 PM, Shawn Lu <shawn.lu@ericsson.com> wrote:
> ...
> If sk->sk_bound_dev_if has a value, =A0we are not going to use
> outif_index anywhere. Seting outif_index is confusing in this case,
>
> In addition, =A0when socket has bond to specific device, this
> Option should return fail to indicate it is wrong to use =A0IP_UNICAS=
T_IF
> Here.

Ok.

Erich Hoover
ehoover@mines.edu
