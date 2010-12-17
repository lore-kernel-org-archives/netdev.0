From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Driver issue on Linux 2.6.35-22-generic-pae #33-Ubuntu SMP
Date: Fri, 17 Dec 2010 22:14:22 +0100
Message-ID: <20101217211422.GA4770@electric-eye.fr.zoreil.com>
References: <CB723940FBFB4D13BBE4C9AF2700F00A.MAI@omegasrvshn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Colum.Flannigan@omegasrvshn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38408 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755671Ab0LQVO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 16:14:26 -0500
Content-Disposition: inline
In-Reply-To: <CB723940FBFB4D13BBE4C9AF2700F00A.MAI@omegasrvshn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colum.Flannigan@omegasrvshn.com <Colum.Flannigan@omegasrvshn.com> :
[...]
> I am writing to this address as it is the address listed in the mod info.

Please be nice with me and cut your lines below 80 characters.

> I purchased 3 of your cards for my infrastucture and am haven an issue with
> my linux system i am testing this on. Currently i have 1 card installed on
> this system and it is working fine, however the gigabit card i got from
> Netgear does not show in the system.

You forgot to specify the kind of card you are using.

(3x) Netgear GA311 ?

> I have checked my dmesg's and have no errors relatting to this and
> the lsmod command does not show it in the list...

The device driver can not help much as long as lsmod does not list
the card. If it is a PCI device detection problem (i.e. card correctly
inserted, slot and card ok), you may take it on linux-kernel but you
will probably be required to try a more recent kernel and provide more
info (lspci -H1 and -H2 output, dmesg, etc.).

-- 
Ueimor
