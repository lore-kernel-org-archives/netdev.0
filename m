From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Tue, 30 Nov 2010 11:01:44 +0100
Message-ID: <1291111304.2904.20.camel@edumazet-laptop>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rui <wirelesser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51953 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156Ab0K3KBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 05:01:48 -0500
Received: by bwz15 with SMTP id 15so4837587bwz.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 02:01:47 -0800 (PST)
In-Reply-To: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 17:22 +0800, Rui a =C3=A9crit :

> step 0:
> launch 4 tcpdump processes,each applied a filter to filter out some
> GTP-U packets. seen with 'tcpdump -d', the bpf code has about 100
> lines.

So each incoming packet has to go through your 4 filters, thats a total
of ~400 bpf instructions. (a bit less in average because of the
conditionnal branches)



