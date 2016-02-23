From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Variable download speed
Date: Tue, 23 Feb 2016 09:26:46 -0500
Message-ID: <CADVnQy=-oh7Ue=Y0vP4ioGrRs7SeJBNq5bkkDVkpogyLpr+9zA@mail.gmail.com>
References: <alpine.LNX.2.20.1602231216240.29937@localhost.localdomain>
	<CADVnQyngzgLhbo6of1vTq5MH4mk4rSR6_KLWCCXkndK6QYynAw@mail.gmail.com>
	<alpine.LNX.2.20.1602231455260.29937@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: sdrb@onet.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36026 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbcBWO0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 09:26:47 -0500
Received: by mail-ob0-f175.google.com with SMTP id gc3so195209886obb.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 06:26:46 -0800 (PST)
In-Reply-To: <alpine.LNX.2.20.1602231455260.29937@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 8:57 AM,  <sdrb@onet.eu> wrote:
> I published example pcap file under following link:
>
> https://www.dropbox.com/s/v8375ub16seyt1a/test7.pcap?dl=0
>
> I hope it is possible to download it without creating dropbox account.

Thanks for the trace. It looks like for the first 0.8 seconds of the
trace some non-TCP component on the receiving machine (app, CPU, CPU
power-saving mechanisms, NIC, or NIC driver) is limiting throughput to
78Mbit/sec (e.g. the very first window of 10 packets is ACKed at that
rate). Then the throughput increases to over 200 Mbit/sec. AFAICT it
doesn't look like the TCP layer is doing anything wrong. I'd look for
issues with those other components. It might help to report the
receiver application, receiver CPU type, kernel version, NIC, and NIC
driver.

neal
