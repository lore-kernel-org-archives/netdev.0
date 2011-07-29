From: T C <tccheung1@gmail.com>
Subject: Kernel IPSec Questions
Date: Thu, 28 Jul 2011 22:40:15 -0700
Message-ID: <CAL0-=Wwb+T_VYgMnOW9UiqQ2gVe8FaJCZgcFmHMLX1Yv3tVAdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:59471 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab1G2FkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 01:40:15 -0400
Received: by iyb12 with SMTP id 12so3625268iyb.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 22:40:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have some questions on how IPSec logic works in the kernel.  There might be
a difference between when XFRM was introduced and prior.  If possible,
I like to know both scenarios.  If not, at least from XFRM perspective would
be very helpful.

Specifically, I am interested in knowing how does IPSec obtain the initial keys
from IKE exchange (and likely from XFRM) to set up the SA.   Also what happens
during rekeying?  Does the SA have to be terminated first, or somehow it can be
rekey'ed and continue as the same SA?  I'll be using strongswan for IKE.

Function names and if possible some flow graphs would be greatly appreciated.

Thanks,
Terry
