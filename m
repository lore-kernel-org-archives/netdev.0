From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Fri, 16 Jan 2009 09:51:37 +0300
Message-ID: <49702E79.6040100@bigtelecom.ru>
References: <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net>	<20090114063909.GA4234@ff.dom.local>	<200901141417.58667.denys@visp.net.lb>	<1231937404.14825.4.camel@laptop>	<Pine.LNX.4.64.0901141748300.17915@nacho.alt.net>	<20090115065322.GA4190@ff.dom.local>	<Pine.LNX.4.64.0901150724000.20461@nacho.alt.net>	<20090115075450.GB4190@ff.dom.local>	<20090115094530.GG4190@ff.dom.local>	<Pine.LNX.4.64.0901151139440.20461@nacho.alt.net>	<20090115121801.GH5461@ff.dom.local> <Pine.LNX.4.64.0901151340540.20461@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Caputo <ccaputo@alt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:60603 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758610AbZAPGvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 01:51:41 -0500
In-Reply-To: <Pine.LNX.4.64.0901151340540.20461@nacho.alt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Caputo =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, 15 Jan 2009, Jarek Poplawski wrote:
>  =20
>> On Thu, Jan 15, 2009 at 12:00:50PM +0000, Chris Caputo wrote:
>> ...
>>    =20
>>> I wish I had a repro scenario in a non-production environment, so I=
 could=20
>>> help out further with this.  If I did, I would test without nmi_wat=
chdog=20
>>> while trying just 2.6.28 and Jarek's #4 patch.
>>>      =20
>> I think this watchdog doesn't matter too much yet. Probably it's mor=
e
>> about hardware (smp, maybe kind of hw timer), and high traffic vs. h=
tb
>> rules.
>>    =20
>
> Per Thomas' comment in http://bugzilla.kernel.org/show_bug.cgi?id=3D1=
0944=20
> regarding broken hrtimers:
>
> --
>   nmi_watchdog=3D1 disables the local apic timers and therefor highre=
s/nohz
>
>   Try to use nmi_watchdog=3D2 instead.
> --
>
> Chris
>
>
>  =20
Oh... after first deadlocks i add nmi_watchdog=3D1 to kernel and test w=
ith
it. Is this result what highres/nohz
allways on and my message where i say what test bug which highres/nohz
on/off is wrong?

