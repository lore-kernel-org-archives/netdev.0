From: Olaf van der Spek <ml@vdspek.org>
Subject: Re: loopback IP alias breaks tftp?
Date: Mon, 10 Oct 2011 17:25:24 +0200
Message-ID: <CAGVGHmt4_kf5XTS745aMa9kuxb1Fu9v8f6boG-vewVeto5jJ=w@mail.gmail.com>
References: <20111005202723.GE2479@zod.bos.redhat.com>
	<alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
	<20111006132353.GF2479@zod.bos.redhat.com>
	<CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
	<1317972573.3457.55.camel@edumazet-laptop>
	<20111007114017.GA1165@zod.bos.redhat.com>
	<1317989073.3207.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1317990201.3207.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111010151058.GD1165@zod.bos.redhat.com>
	<CAGVGHmsF3JBqpqzKa_Fp6oOcVKX5BKgJUG=UJvPZcNgKiSsrRA@mail.gmail.com>
	<1318260126.3227.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Josh Boyer <jwboyer@redhat.com>, Joel Sing <jsing@google.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	francis.souyri@apec.fr
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:40843 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab1JJPZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 11:25:25 -0400
Received: by vcbgb30 with SMTP id gb30so749029vcb.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 08:25:25 -0700 (PDT)
In-Reply-To: <1318260126.3227.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2011 at 5:22 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Isn't that a bad way to work around this issue?
>> It'd require you to duplicate your IP config for every daemon that
>> listens on UDP interfaces.
>> What about IP addresses that are added/deleted after the daemon is launchad?
>>
>> Olaf
>
> Thats a pretty common problem, even prior to discussed commit.
>
> If you take a look at common UDP daemons, they have to setup a listener
> for each IP address, OR use the correct API ( setsockopt(fd, IPPROTO_IP,
> &on, sizeof(on)) and handle IP_PKTINFO ancillary message)

Only the latter solution seems right.

Olaf
