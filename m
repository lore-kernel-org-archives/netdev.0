From: Santiago Garcia Mantinan <manty@manty.net>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Fri, 2 Aug 2013 09:26:46 +0200
Message-ID: <CAJk_L2H+Y4u=DtLXe_R9R79z6tUt8F3=16YwRvh12CxENm7Aaw@mail.gmail.com>
References: <20130801121142.GA444@www.manty.net>
	<20130801130058.GA13602@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:47165 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390Ab3HBH0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 03:26:47 -0400
Received: by mail-qc0-f172.google.com with SMTP id a1so160949qcx.17
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 00:26:47 -0700 (PDT)
In-Reply-To: <20130801130058.GA13602@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/1 Erik Hugne <erik.hugne@ericsson.com>
> This have helped me troubleshoot various bonding problems in the past:
> mount -t debugfs none /sys/kernel/debug/
> ln -s /sys/kernel/debug /debug
> echo -n 'module bonding +p' > /debug/dynamic_debug/control

I'm compiling a 3.11-rc3 version with dynamic_debug enabled in order
to be able to test this.

> Did you sniff externally, on the native device, bond slaves or on bond0?

The sniffing was done on both the bonding host (eth0 device) and the
remote host, the one with just the vlan.

Regards.
-- 
Manty/BestiaTester -> http://manty.net
