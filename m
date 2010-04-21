From: Timur Tabi <timur.tabi@gmail.com>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Wed, 21 Apr 2010 09:33:56 -0500
Message-ID: <z2ged82fe3e1004210733v8fa40902k664549aa9620b13@mail.gmail.com>
References: <o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com>
	<20100420.180646.216759318.davem@davemloft.net> <A20F7457-20BC-493C-B800-3933D8FC4D5C@kernel.crashing.org>
	<20100420.223659.236667659.davem@davemloft.net> <10AE27BE-1830-4AAD-83E6-20001BC430D8@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, afleming@freescale.com,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:53670 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755296Ab0DUOe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 10:34:26 -0400
Received: by pwj9 with SMTP id 9so5125271pwj.19
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 07:34:26 -0700 (PDT)
In-Reply-To: <10AE27BE-1830-4AAD-83E6-20001BC430D8@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 7:17 AM, Kumar Gala <galak@kernel.crashing.org> wrote:

> I understand, its more a sense that we are saying we want to time out for what I consider a catastrophic HW failure.

And how else will you detect and recover from such a failure without a
timeout?  And are you absolutely certain that there will never be a
programming failure that will cause this loop to spin forever?

If you're really opposed to a timeout, you can still use
spin_event_timeout() by just setting the timeout to -1 and adding a
comment explaining why.

-- 
Timur Tabi
Linux kernel developer at Freescale
