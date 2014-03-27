From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: significant napi_gro_frags() slowdown
Date: Thu, 27 Mar 2014 09:47:54 -0700
Message-ID: <1395938874.12610.306.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5334542F.1050702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:47304 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbaC0Qr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:47:58 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl14so3742559pab.4
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:47:57 -0700 (PDT)
In-Reply-To: <5334542F.1050702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 17:39 +0100, Michal Schmidt wrote:
> Hello,
> 
> I received a report about a performance regression on a simple workload 
> of receiving a single TCP stream using a be2net NIC. Previously the 
> reporter was able to reach more than 9 Gb/s, but now he sees less than 7 
> Gb/s.

Yeah, we are aware of this, and we had some discussions, but not yet got
a fix.

Are you running a 64 or 32bit kernel BTW ?
