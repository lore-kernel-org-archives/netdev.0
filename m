From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2/m_ipt fix, opts was not set properly
Date: Wed, 06 Aug 2008 07:18:16 -0400
Message-ID: <1218021496.4755.54.camel@localhost>
References: <200808052224.36773.denys@visp.net.lb>
	 <1218019350.4755.30.camel@localhost> <1218019945.4755.36.camel@localhost>
	 <200808061402.01021.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:38243 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764610AbYHFLST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 07:18:19 -0400
Received: by an-out-0708.google.com with SMTP id d40so497038and.103
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 04:18:18 -0700 (PDT)
In-Reply-To: <200808061402.01021.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-08 at 14:02 +0300, Denys Fedoryshchenko wrote:

> Does it work on my test batch?

I havent tested with your scenario as i am staring at your script
and trying to construct a simple case. It was just eyeballing.
The original code was not resetting the  contents "pointed to"
by opts. So on return from free_opts, nothing has changed really.

> Your way looks much more clean :-)
> (I cannot test it properly, since i have modified iproute2 now)

It should work but i will test it. The simple test case i can think of
is to have two ipt invocations with different parameters (eg mark and
set tos).
If you test it, please resubmit with new approach. I will let you know
my results (as i have a few vacation hours to kill this morning).

cheers,
jamal

