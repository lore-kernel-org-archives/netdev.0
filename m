From: Olaf van der Spek <ml@vdspek.org>
Subject: Re: loopback IP alias breaks tftp?
Date: Mon, 10 Oct 2011 17:15:23 +0200
Message-ID: <CAGVGHmsF3JBqpqzKa_Fp6oOcVKX5BKgJUG=UJvPZcNgKiSsrRA@mail.gmail.com>
References: <20111005202723.GE2479@zod.bos.redhat.com>
	<alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
	<20111006132353.GF2479@zod.bos.redhat.com>
	<CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
	<1317972573.3457.55.camel@edumazet-laptop>
	<20111007114017.GA1165@zod.bos.redhat.com>
	<1317989073.3207.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1317990201.3207.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111010151058.GD1165@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Joel Sing <jsing@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org, francis.souyri@apec.fr
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:37218 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab1JJPPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 11:15:24 -0400
Received: by vcbgb30 with SMTP id gb30so740147vcb.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 08:15:24 -0700 (PDT)
In-Reply-To: <20111010151058.GD1165@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, Oct 07, 2011 at 02:23:21PM +0200, Eric Dumazet wrote:
>> By the way, there is no need for tftp change :
>>
>> Just launch several tftpd instances, and bind each them to one
>> particular IP.
>>
>> If started from xinetd.d :

Isn't that a bad way to work around this issue?
It'd require you to duplicate your IP config for every daemon that
listens on UDP interfaces.
What about IP addresses that are added/deleted after the daemon is launchad?

Olaf
