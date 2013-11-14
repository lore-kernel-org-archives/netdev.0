From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel
 > 3.10
Date: Thu, 14 Nov 2013 08:47:28 +0100
Message-ID: <52848010.8030103@profihost.ag>
References: <52838590.5070806@profihost.ag> <20131113141244.GM19702@redhat.com> <52838AC8.8070005@profihost.ag> <52839540.6020908@gmail.com> <5283980D.7020508@profihost.ag> <20131113162136.GP19702@redhat.com> <5283B500.9040408@gmail.com> <5283DC91.1010402@profihost.ag> <52843EEA.3020905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: vyasevic@redhat.com, Vlad Yasevich <vyasevich@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:39078 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab3KNHrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:47:36 -0500
In-Reply-To: <52843EEA.3020905@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> eth2
>      \
>       -- bond1 -- vmbr1
>      /     \
> eth3        ----- bond1.3000 --- vmbr1v3000
>                                      \ ---- tap114i1

thos one works fine now.


> eth2
>      \
>       -- bond1 -- vmbr1
>      /              \
> eth3                 \ vmbr1.3000
>                            \ ---- tap114i1

this one does not. Another note to this one. It also never worked on
RHEL6 - it started working with about 2.6.39 and stopped with 3.9 or
3.10. But it was the only one where gvrp on vlans had worked.

Greets,
Stefan
