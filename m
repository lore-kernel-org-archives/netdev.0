From: "Figo.zhang" <figo1802@gmail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Fri, 05 Mar 2010 22:07:57 +0800
Message-ID: <1267798077.2576.17.camel@myhost>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	 <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:36791 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516Ab0CEOIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 09:08:07 -0500
Received: by pzk32 with SMTP id 32so1373575pzk.4
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 06:08:05 -0800 (PST)
In-Reply-To: <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> My tests look like following:
> 
> 1. system start
> 2. ping one host: O.K.
> 3. nc -l -p 5000 > /var/test (about 1Mb): O.K.
> 4. ping the same host: failed
1. type "arp" command, see the arp is exit or expire?
2. at this point, see is it still have RX interrpt and receive packet in
ks8695_rx()? (in some watchpoint add printk). 

> 
> and even if the fourth test succeeds, if I then send a file from other
> host the next ping or any other communication fails. I just tried to
> make some SSH sessions. It goes without a problem till I issue a ping
> after that.
> 
> If I test the system with nuttcp I have no problem.
> 
> Do you have any idea how to debug this? If I remove the NAPI support I
> have no problem with the same kernel and environment. I'd really like
> to get the whole stuff working.
> 
> Regards,
> Yegor


