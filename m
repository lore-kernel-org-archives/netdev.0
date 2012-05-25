From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: Using jiffies for tcp_time_stamp?
Date: Fri, 25 May 2012 09:58:40 -0600
Message-ID: <4FBFAC30.8050508@genband.com>
References: <CAACrLC39Xdm3vTKUsjz43ZPyEq_vHxR-_Uf56SjSm+kUqxOqZg@mail.gmail.com> <CAACrLC2CXU-DNeonWQGJTfX53ssm_asK7WQrFuWRBB77cg-YdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?U3JlxIdrbyBKdXJpxIctS2F2ZWxq?=
	<srecko.juric-kavelj@fer.hr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og123.obsmtp.com ([64.18.2.24]:47490 "EHLO
	exprod7og123.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169Ab2EYP6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 11:58:51 -0400
In-Reply-To: <CAACrLC2CXU-DNeonWQGJTfX53ssm_asK7WQrFuWRBB77cg-YdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2012 11:21 AM, Sre=C4=87ko Juri=C4=87-Kavelj wrote:

> By looking at the code it's clear that the time stamping is done with
> jiffies, and my kernel has CONFIG_HZ=3D100.
>
> I understand that this is for performance reasons (and the RTT
> smoothing filter is implemented with bit shifting operations), but
> would using a more precise time stamp have significant impact on
> performance? Since RTT is used to compute RTO, wouldn't there be any
> benefits of having more accurate estimate of this value?

I don't know if it would make any difference to the tcp algorithms, but=
=20
certainly on some architectures you can get a fast and accurate hardwar=
e=20
timestamp.

Chris
