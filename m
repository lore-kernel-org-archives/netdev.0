From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] pkt_sched: fq: avoid hang when quantum 0
Date: Tue, 03 Feb 2015 09:46:09 -0800
Message-ID: <1422985569.907.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422982158-12530-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:64898 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966621AbbBCRqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 12:46:12 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so27018326iec.0
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 09:46:11 -0800 (PST)
In-Reply-To: <1422982158-12530-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 17:49 +0100, Kenneth Klette Jonassen wrote:
> Configuring fq with quantum 0 hangs the system, presumably because of a
> non-interruptible infinite loop. Either way quantum 0 does not make sense.
> 
> Reproduce with:
> sudo tc qdisc add dev lo root fq quantum 0 initial_quantum 0
> ping 127.0.0.1
> 
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
