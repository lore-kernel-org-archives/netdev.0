From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Performance issue : GRE tunneling
Date: Fri, 18 Jan 2008 18:08:03 +0300
Message-ID: <4790C0D3.8050202@bigtelecom.ru>
References: <1200664092.22132.3.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, matthew.hattersley@vaioni.com
To: Jeba Anandhan <jeba.anandhan@vaioni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:49653 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769AbYARPIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 10:08:12 -0500
In-Reply-To: <1200664092.22132.3.camel@vglwks010.vgl2.office.vaioni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeba Anandhan =EF=E8=F8=E5=F2:
> Hi All,
> When i send the traffic outside of GRE tunnel, The speed is in 3-4Mbp=
s.
> When i use the tunnel for traffic, the speed get reduced huge. It is
> around 100-300Kbps. What are the factors affects the performance when=
 we
> use tunneling [ ex:GRE tunneling ]?
>  =20
Hello. You may try get slow place. Get pc without CPU load (console mod=
e=20
and etc).
Try compile gre support in kernel. Turn on OPROFILE support.
Install oprofile utils.
do
opcontrol --vmlinux=3D/usr/src/linux/vmlinux
opcontrol -s
#do connect and try do traffic.
opreport -l | vi -
# you see that functions in kernel use cpu...
opcontrol -h #to stop

Maybe its help for you. Thanks!
> Thanks
> Jeba
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  =20

