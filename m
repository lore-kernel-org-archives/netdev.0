From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH ] net_sched: actions - Add default lookup
Date: Sun, 17 Nov 2013 10:46:10 -0500
Message-ID: <5288E4C2.9090405@mojatatu.com>
References: <5270ECB5.2030601@mojatatu.com>	<1383141605.4857.38.camel@edumazet-glaptop.roam.corp.google.com>	<20131103.231232.1438716028901698864.davem@davemloft.net> <20131103.231729.12647956618590906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:62830 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab3KQPqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 10:46:22 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so1454494iec.5
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 07:46:20 -0800 (PST)
In-Reply-To: <20131103.231729.12647956618590906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/13 23:17, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 03 Nov 2013 23:12:32 -0500 (EST)
>
>> Right, and BUG() if we try to register and action with a NULL .lookup
>> member.
>
> I return an error, BUG() is too harsh.
>

Sorry - I was distracted, but have time now.
I wanted to fix this then send the other patches - but confused.
We are setting the default if someone registers an action with
a NULL .lookup. Why do we want to return an error?

cheers,
jamal
