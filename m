From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: tcpdump broke in 2.6.34-rc1
Date: Fri, 12 Mar 2010 14:50:31 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003121450050.14684@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1003120037050.22042@obet.zrqbmnf.qr> <201003121424.00868.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:52578 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757656Ab0CLNuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Mar 2010 08:50:32 -0500
In-Reply-To: <201003121424.00868.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 2010-03-12 14:23, Frans Pop wrote:

>Jan Engelhardt wrote:
>> I am currently on 2.6.34-rc1 and found that tcpdump no
>> longer works (dies with setsockopt: invalid argument). Bisect-narrowed
>> it down to somewhere between
>
>Probably the same as http://lkml.org/lkml/2010/3/9/439, which has an exact 
>bisect.
>
>Has a follow-up that it's fixed by
>http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=1162563f82b434e3099c9e6c1bbdba846d792f0d

Thanks for looking it up. The patch does indeed fix the issue.
