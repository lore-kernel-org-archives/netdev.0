From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH v6 1/2] Implement IP_UNICAST_IF socket option.
Date: Tue, 7 Feb 2012 18:10:05 -0700
Message-ID: <CAEU2+vrfMXXr1S0BYtN07uwXfK8T8A_ob3PR3RoHOdqdFv0YEg@mail.gmail.com>
References: <62162DF05402B341B3DB59932A1FA992B5B5D1FC8A@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:56271 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756509Ab2BHBKH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 20:10:07 -0500
Received: from mail-tul01m020-f174.google.com (mail-tul01m020-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q181A5We020535
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 7 Feb 2012 18:10:06 -0700
Received: by obcva7 with SMTP id va7so56931obc.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 17:10:05 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5D1FC8A@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2012 at 5:23 PM, Shawn Lu <shawn.lu@ericsson.com> wrote:
>> ...
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 ifindex =3D (__force int)ntohl=
((__force __be32)val);
> We always use ifindex as host byte order, why the val=A0 is passed in=
 as
> network byte order and then convert it
> Back to host byte order. Anything special about it?

Yes, the value for IP_UNICAST_IF is passed in network byte order in
implementations on other operating systems.  David Miller requested
that this option by passed in the same way as that of other systems.

Erich Hoover
ehoover@mines.edu
