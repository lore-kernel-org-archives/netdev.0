From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: how many msi (msi-x) vectors can be setup?
Date: Wed, 19 May 2010 13:33:20 -0700
Message-ID: <AANLkTimrQPhPomBC-x-E0b9BKDUmO2j2flZp_Qm2aAtK@mail.gmail.com>
References: <AANLkTikT3ThBnO8q3AvhS9t4jUu8npOwYmjY6WUMhseq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zhou rui <wirelesser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:55001 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049Ab0ESUdV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 16:33:21 -0400
Received: by pwi5 with SMTP id 5so1728834pwi.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 13:33:21 -0700 (PDT)
In-Reply-To: <AANLkTikT3ThBnO8q3AvhS9t4jUu8npOwYmjY6WUMhseq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 8:18 AM, zhou rui <wirelesser@gmail.com> wrote:
> hi there:
> how many msi (msi-x) vectors can be setup?
> the number is limited by hardware resource(nic), or kernel ?
> I found that the driver (broadcom 57711 ver 1.5.12) tried to request
> 16 queues on my kernel2.6.27,but only 2=A0 available
> will it be increased if I update the driver or kernel?
> and there is a limitiation in the system? if the other devices have
> already occupied too many MSI vectors then it is not enough.

from kernel 2.6.19 x86_64, there is per-cpu vector irq support.

depends your system : CPU num? 64bit or 32bit.

YH
