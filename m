From: Min Zhang <mzhang@mvista.com>
Subject: Re: possible kernel oops from user MSS
Date: Fri, 12 Nov 2010 14:59:58 -0800
Message-ID: <4CDDC6EE.2010005@mvista.com>
References: <AANLkTimMDMb74-3E9vhFxZ5Dgeuk3HMzPZVjwCj+yFEJ@mail.gmail.com>	<20101110.124119.102563803.davem@davemloft.net> <AANLkTin-gXceUQxKvQeP8Nc8oXZDJnyjoFUjYD5x_g_y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:63700 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140Ab0KLXAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 18:00:08 -0500
Received: by ywc21 with SMTP id 21so911917ywc.19
        for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 15:00:07 -0800 (PST)
In-Reply-To: <AANLkTin-gXceUQxKvQeP8Nc8oXZDJnyjoFUjYD5x_g_y@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Regarding commit 7a1abd08d52fdeddb3e9a5a33f2f15cc6a5674d2 ("tcp:
Increase TCP_MAXSEG socket option minimum"). What is the reason
TCP_MAXSEG minimum be 64? Isn't the exact be 40 which is
TCPOLEN_MD5SIG_ALIGNED(20) + TCPOLEN_TSTAMP_ALIGNED(12) + 8?

Or is it better to use TCP_MIN_MSS from tcp.h:

/* Minimal accepted MSS. It is (60+60+8) - (20+20). */
#define TCP_MIN_MSS        88U
