From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Thu, 20 Jun 2013 20:44:39 +0200
Message-ID: <51C34D97.5030803@redhat.com>
References: <1371663286-12518-7-git-send-email-vfalico@redhat.com> <51C2299C.2040403@redhat.com> <20130619222459.GB10910@redhat.com> <51C230D2.5070405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161036Ab3FTSpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 14:45:51 -0400
In-Reply-To: <51C230D2.5070405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/06/13 00:29, Nikolay Aleksandrov wrote:
<snip>
> Yes, but it is set only if there're targets already present that's why I
> said after enslaving. In the case of later target addition
> target_last_arp_rx[0] will be 0 and last_arp_rx will be set.
> 
> Cheers,
>  Nik
Disregard this, I'm blind :-) just now noticed that they're set
unconditionally.

Nik
