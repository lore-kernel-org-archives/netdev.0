From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v5 09/11] act_police: improved accuracy at high
 rates
Date: Tue, 12 Feb 2013 08:31:21 -0500
Message-ID: <511A4429.2040908@mojatatu.com>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us> <1360663929-1023-10-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:37407 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933260Ab3BLNbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 08:31:24 -0500
Received: by mail-ie0-f173.google.com with SMTP id 9so84786iec.4
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 05:31:24 -0800 (PST)
In-Reply-To: <1360663929-1023-10-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri,

Does this work with your new kernel changes + old tc?
Some of the kernel fields you have changes that are updated from
user space with matching 32 bits (eg the pair tcfp_burst which you made 
64 bits vs user space u32 burst).
It probably will work - doesnt harm to check on _all_ the fields you
upgraded to 64 bit.

cheers,
jamal
