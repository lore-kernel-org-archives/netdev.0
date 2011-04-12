From: zhou rui <zhourui.cn@gmail.com>
Subject: profile my proto_hook.function
Date: Tue, 12 Apr 2011 22:00:24 +0800
Message-ID: <BANLkTi==HczThr66Yr0-Rm-RkEUw44sqrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62818 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461Ab1DLOAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 10:00:24 -0400
Received: by iwn34 with SMTP id 34so6666396iwn.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 07:00:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi
I used a prot_hook(added via dev_add_pack,protocol=ETH_P_ALL) to
process packets in kernel part.but the performance was bad

ksoftirqd used almost 100% cpu on my 1G nic(intel e1000,w/o RSS) XEON
5400 hypertown machine.

looks my  packet processing is too slow. but how to profile this?
i.e. how many CPU resources used in softirq and normal kernel protocol
stack(tcp/ip,etc)
and how many used in my packet processing function?

and any idea to improve it?how about moving the processing function to driver?

thanks
rui
