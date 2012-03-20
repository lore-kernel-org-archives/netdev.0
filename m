From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: Per TCP session statistics
Date: Tue, 20 Mar 2012 13:26:14 +0000
Message-ID: <CAAMvbhFpCO0GCgYY=ckHWDBPLnj9Szs5jbGQuZcuDjNfJSWqvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:34080 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758574Ab2CTN0P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 09:26:15 -0400
Received: by qcqw6 with SMTP id w6so14016qcq.19
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2012 06:26:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is there a way to gather stats for each TCP session?
The stats I am looking for are periodic sampling of the following metrics:

Statistics         Defnition
Cwin                Current congestion window
Rwin                Current receive window
BytesInFlight     # of bytes sent but not ACKed
BytesInSndBuf   # of bytes written but not ACKed
SmoothedRTT    Smoothed RTT computed by TCP
BytesWritten    Cumulative # of bytes written by app
BytesSent       Cumulative # of bytes sent
PktsRetrans     Cumulative # of pkts retransmitted
RwinLimitTime   Cumulative time that a connection is limited by receive window
CwinLimitTime   Cumulative time that a connection is limited by
congestion window

So, for example,
1) I could say that all TCP sessions being listened to by process ID
2002 will get stats written to a file per tcp session per 60 seconds.
2) Gather local statistics for all TCP sessions initiated by process "firefox".

Does there already exit such a tool for Linux?

Kind Regards
