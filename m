From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH v3 2/2] Implement IPV6_UNICAST_IF socket option.
Date: Mon, 6 Feb 2012 20:23:53 -0700
Message-ID: <CAEU2+vqBrkh0Wab9r3PAVAWTiTGC7NwW_Nh862izCsyipPzd_w@mail.gmail.com>
References: <1328551064-28573-2-git-send-email-ehoover@mines.edu>
	<4F30428B.2080102@hp.com>
	<CAEU2+vr823WcoF_Z4NV7ptWNBQ4uTG+tD2VAXbQPDYGqsaKpLQ@mail.gmail.com>
	<4F3093B5.5070801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:47228 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755887Ab2BGDXz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 22:23:55 -0500
Received: from mail-vx0-f174.google.com (mail-vx0-f174.google.com [209.85.220.174])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q173NsSw017044
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 6 Feb 2012 20:23:54 -0700
Received: by vcge1 with SMTP id e1so4370408vcg.19
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 19:23:54 -0800 (PST)
In-Reply-To: <4F3093B5.5070801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2012 at 8:00 PM, Brian Haley <brian.haley@hp.com> wrote:
> On 02/06/2012 05:11 PM, Erich E. Hoover wrote:
>> ...
>> I'll double check all of these tonight, but a cursory look seems to
>> indicate that the multicast check is the right place to put this for
>> all the files. =A0I'm sorry about that, I clearly didn't consider
>> interfering with multicast.
>
> It's probably important to keep the precedence the same as before:
>
> =A0 =A0 =A0 =A0SO_BINDTODEVICE
> =A0 =A0 =A0 =A0IPV6_PKTINFO
> =A0 =A0 =A0 =A0IPV6_*CAST_IF
> ...

I agree, I mean that the IP*_MULTICAST_IF location appears to be the
correct place to put IP*_UNICAST_IF.  I'll post a revision after I've
had a chance to test it.

Erich Hoover
ehoover@mines.edu
