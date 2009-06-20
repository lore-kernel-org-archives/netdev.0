From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: hunging ifenslave command
Date: Sat, 20 Jun 2009 15:36:21 +0200
Message-ID: <4A3CE5D5.8070308@gmail.com>
References: <4A3A3DEA.20602@onet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sdrb <sdrb@onet.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f214.google.com ([209.85.220.214]:44770 "EHLO
	mail-fx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbZFTNgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 09:36:38 -0400
Received: by fxm10 with SMTP id 10so151486fxm.37
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2009 06:36:39 -0700 (PDT)
In-Reply-To: <4A3A3DEA.20602@onet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sdrb wrote, On 06/18/2009 03:15 PM:

> Hello,
> 
> I have got problem with hunging "ifenslave" command.
> I configured bond0 interfaces with 3 slaved interfaces: eth0, eth1 and 
> eth2. While I'm removing one of it - sometimes only the "ifenslave" 
> command hangs up but sometimes the whole system is hanging up completely 
> - so it's not possible to even write on the console.
> 
> I'm using linux kernel 2.6.27.10 with bonding driver version v3.3.0 
> (June 10, 2008) and ethernet card driver r8168 version 8.006.00-NAPI.
> 
> Anyone knows where is the problem with it?


Hi,

I don't know, but I guess, if anyone knew it would be fixed now. So, I'd
recommend trying the current stable (2.6.30), and if no difference, maybe
some debugging like turning on lockdep (lock debugging with prove
locking correctness). If still nothing reported, try to get a few SysRq
logs when it happens e.g. Alt-PrtScr with t, d, w, q, and send them with
.config and dmesg (gzipped or as attachments to the bugzilla report).

Jarek P.
