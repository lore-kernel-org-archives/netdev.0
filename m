From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 09:01:55 +0100
Message-ID: <4D0F0D73.2080807@itcare.pl>
References: <4D0DEDF9.7020102@itcare.pl> <1292773433.18869.153.camel@edumazet-laptop> <4D0E2E52.3090802@itcare.pl> <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com> <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com> <4D0E857E.5060302@gmail.com> <4D0E868F.90005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:43428 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753898Ab0LTIB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 03:01:57 -0500
In-Reply-To: <4D0E868F.90005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-12-19 23:26, Jarek Poplawski pisze:
> Jarek Poplawski wrote:
>> Jarek Poplawski wrote:
>>> Pawe=C5=82 Staszewski wrote:
>>>> for sch_generic.h was ok.
>>> Should be enough to try after reverting this sch_generic.h change o=
nly.
>> Hmm... Sorry, I meant the change inside skb_act_clone(). I'll send a=
 patch.
> Here it is.
>
> Jarek P.
>
Yes reverting this patch solves the problem.


Thanks
Pawe=C5=82


