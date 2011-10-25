From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: make bonding slaves honour master's skb->priority
Date: Tue, 25 Oct 2011 09:25:25 -0700
Message-ID: <CANP3RGeMbVFf6oL3+9i8h43q1ycdzcA47rNfzeyLWpi8M8ZV5w@mail.gmail.com>
References: <1319517660-22085-1-git-send-email-zenczykowski@gmail.com>
	<1319519056-21677-1-git-send-email-zenczykowski@gmail.com>
	<20111025110808.27db8487@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:57664 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab1JYQZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 12:25:28 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p9PGPRdf027477
	for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 09:25:27 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq13.eem.corp.google.com with ESMTP id p9PGPFUu014843
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 09:25:26 -0700
Received: by pzk2 with SMTP id 2so2499116pzk.0
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 09:25:25 -0700 (PDT)
In-Reply-To: <20111025110808.27db8487@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I tripped on it few times and never understood why we
> were fixing the priority at this point.
> thanks,

It looks like ancient code, going all the way back to something like
Linux 2.4.14 (if I recall my git blame session correctly).
I can't think of a good reason for this...

- Maciej
