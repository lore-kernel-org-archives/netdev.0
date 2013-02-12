From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 09/11] act_police: improved accuracy at high
 rates
Date: Tue, 12 Feb 2013 14:39:15 +0100
Message-ID: <20130212133915.GA18057@minipsycho.orion>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
 <1360663929-1023-10-git-send-email-jiri@resnulli.us>
 <511A4429.2040908@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42235 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759109Ab3BLNjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 08:39:22 -0500
Received: by mail-ee0-f46.google.com with SMTP id e49so48789eek.5
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 05:39:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <511A4429.2040908@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 12, 2013 at 02:31:21PM CET, jhs@mojatatu.com wrote:
>Jiri,
>
>Does this work with your new kernel changes + old tc?
>Some of the kernel fields you have changes that are updated from
>user space with matching 32 bits (eg the pair tcfp_burst which you
>made 64 bits vs user space u32 burst).
>It probably will work - doesnt harm to check on _all_ the fields you
>upgraded to 64 bit.

Yes, this shouldn't be a problem. Userspace passes this values in
struct tc_police *parm and these values are converted into new 64bits
(ticks->ns) ones. Also in dump functions, these are converted back.

Similar changes were made to htb some time ago, I believe that without
issues.

>
>cheers,
>jamal
