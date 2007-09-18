From: =?ISO-8859-1?Q?Mikael_Leivisk=E4?= <mikael@zero-kelvin.org>
Subject: Problems with 3c59x driver (extremely low throughput)
Date: Tue, 18 Sep 2007 13:32:00 +0200
Message-ID: <46EFB730.2070201@zero-kelvin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zero-kelvin.org ([85.8.2.148]:55904 "EHLO www.zero-kelvin.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755488AbXIRMDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 08:03:44 -0400
Received: from [192.168.0.13] (unknown [192.168.0.13])
	by www.zero-kelvin.org (Postfix) with ESMTP id BC4B83FD4
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 13:32:01 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK first of all I'm not really sure if this is the place but was told b=
y
 Dave Dillow to send to the netdev kernel mailing list. So that's what
I'm doing :)

I tried searching the mailing lists and didn't find anything that seeme=
d
relevant, it is possible I missed something the archives are huge...

=46ollowing is the mail I sent originally:

I've run into something of a strange problem lately, I have a network
card that runs on the Vortex/Boomerang driver. I ran the 2.6.16 kernel
without any issues, and later switched to 2.6.22 because I couldn't get
my IPSEC tunnel working with 2.6.16 for some reason (didn't find the
right switches in menuconfig). And everything was seemingly working fin=
e
but soon after my ISP got some problems and they said they had to
replace some hardware somewhere along my route and now when I access th=
e
internet (the machine is setup as router/web-file-mail-server with this
card as the external interface) I get dreadfully slow speeds, I'll be
lucky to get 10KB/s on a 10MB/s link. But the funny thing is if I switc=
h
to the 2.6.16 kernel, WHAM I get 700KB/s no sweat... The kernel
configurations are otherwise almost exactly the same bar tickless and
some switches in network options to get ipsec... The only thing I do is
change the kernel and things work...

So my questions are,
Has there been any recent changes to the drivers for the card lately?
(between .16 and .22)
Or any changes in the network infrastructure that could be the cause of=
 it?
Or is there some other switch in the config that could be the cause of =
this?
Or is it my ISP's hardware that's not playing nice?
Or any other ideas as to what might be the cause.

I've posted the respective kernel configs, and lspci output and my
cpuinfo on http://www.zero-kelvin.org/pub/kern/

If there is any other info that you need I'll gladly provide it assumin=
g
I can get my hands on it   :)

Oh btw, the affected card is:
00:10.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado]
(rev 74)

Kind regards, Mikael Leivisk=E4

