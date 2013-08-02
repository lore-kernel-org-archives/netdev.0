From: Santiago Garcia Mantinan <manty@manty.net>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Fri, 2 Aug 2013 09:30:29 +0200
Message-ID: <CAJk_L2EfJuit=8tU_vdqOenkBfm4awRz+vspM0DY_q2sQAmdrg@mail.gmail.com>
References: <20130801121142.GA444@www.manty.net>
	<CAE3RKN=AoevKmRDewpmm8TjDasN8k=J4Sny8gCCv6dbOXwHADQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <darkmag@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:62119 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755403Ab3HBHaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 03:30:30 -0400
Received: by mail-qa0-f53.google.com with SMTP id hu14so158573qab.19
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 00:30:29 -0700 (PDT)
In-Reply-To: <CAE3RKN=AoevKmRDewpmm8TjDasN8k=J4Sny8gCCv6dbOXwHADQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/1 Veaceslav Falico <darkmag@gmail.com>:
>>         bond-slaves eth0.1002
>>         bond-mode active-backup
>>         bond-arp_validate 0
> Could you please try with arp_validate=1?

arp_validate=1 was what I first tried, then I thought that making
validations could be dropping packages so I went for the 0
validations, both had the same problem.

Regards.
-- 
Manty/BestiaTester -> http://manty.net
