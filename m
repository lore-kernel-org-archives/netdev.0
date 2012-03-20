From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: Per TCP session statistics
Date: Tue, 20 Mar 2012 15:32:27 +0200
Message-ID: <CAEnQRZBprHhWU442U5Jmq=SPGKaUDD4kPV_M43eKuTakQotctg@mail.gmail.com>
References: <CAAMvbhFpCO0GCgYY=ckHWDBPLnj9Szs5jbGQuZcuDjNfJSWqvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Courtier-Dutton <james.dutton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:39626 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759921Ab2CTNc2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 09:32:28 -0400
Received: by vcqp1 with SMTP id p1so30454vcq.19
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2012 06:32:27 -0700 (PDT)
In-Reply-To: <CAAMvbhFpCO0GCgYY=ckHWDBPLnj9Szs5jbGQuZcuDjNfJSWqvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 20, 2012 at 3:26 PM, James Courtier-Dutton
<james.dutton@gmail.com> wrote:
> Hi,
>
> Is there a way to gather stats for each TCP session?
> The stats I am looking for are periodic sampling of the following met=
rics:
>
> Statistics =A0 =A0 =A0 =A0 Def nition
> Cwin =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Current congestion window
> Rwin =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Current receive window
> BytesInFlight =A0 =A0 # of bytes sent but not ACKed
> BytesInSndBuf =A0 # of bytes written but not ACKed
> SmoothedRTT =A0 =A0Smoothed RTT computed by TCP
> BytesWritten =A0 =A0Cumulative # of bytes written by app
> BytesSent =A0 =A0 =A0 Cumulative # of bytes sent
> PktsRetrans =A0 =A0 Cumulative # of pkts retransmitted
> RwinLimitTime =A0 Cumulative time that a connection is limited by rec=
eive window
> CwinLimitTime =A0 Cumulative time that a connection is limited by
> congestion window
>
> So, for example,
> 1) I could say that all TCP sessions being listened to by process ID
> 2002 will get stats written to a file per tcp session per 60 seconds.
> 2) Gather local statistics for all TCP sessions initiated by process =
"firefox".
>
> Does there already exit such a tool for Linux?

Have a look at ss ([1]).

thanks,
Daniel.

[1] http://linux.die.net/man/8/ss
