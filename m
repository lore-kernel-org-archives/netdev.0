From: Fabio Coatti <fabio.coatti@gmail.com>
Subject: Re: 2.6.39.2 BUG: unable to handle kernel NULL pointer dereference
Date: Sun, 26 Jun 2011 13:34:57 +0200
Message-ID: <BANLkTikhGVYAFEZGS-AZf3CyS4yVN+Acvg@mail.gmail.com>
References: <BANLkTing9LWO6AjbdzOJzkJ9aoJhn_TLnw@mail.gmail.com>
	<1309082172.2532.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51471 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298Ab1FZLe6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 07:34:58 -0400
In-Reply-To: <1309082172.2532.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/6/26 Eric Dumazet <eric.dumazet@gmail.com>:
> Le dimanche 26 juin 2011 =E0 10:28 +0200, Fabio Coatti a =E9crit :
>> I'm trying to boot with 2.6.39.2 but the process stops somewhere in
>> network stack, with a BUG: report.
>> I've been able to capture the kernel messages usign netconsole, so b=
e
>> patient with poor alignment :)

>
> Hi Fabio
>
> Could you test following patch :
>
> http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=
=3Dcommitdiff;h=3D6407d74c5106bb362b4087693688afd34942b094
>
>
> This should be included in 2.6.39.3, if you confirm this fixes the
> problem.
>

Yes, I can confirm that your patch fixes the problem, now running
2.6.39.2 just fine. Many thanks!



--=20
=46abio
