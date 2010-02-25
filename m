From: jamal <hadi@cyberus.ca>
Subject: Re: [Bugme-new] [Bug 15379] New: u32 classifier port range
 calculation error
Date: Thu, 25 Feb 2010 08:24:53 -0500
Message-ID: <1267104293.3973.947.camel@bigi>
References: <bug-15379-10286@http.bugzilla.kernel.org/>
	 <20100224145220.da5ec0b0.akpm@linux-foundation.org>
	 <1267068257.3973.865.camel@bigi>
	 <4a5881461002250325o45965b2fu2855b712b73e00b9@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Reinaldo de Carvalho <reinaldoc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f204.google.com ([209.85.216.204]:51919 "EHLO
	mail-px0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932439Ab0BYNY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 08:24:59 -0500
Received: by pxi42 with SMTP id 42so31746pxi.19
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 05:24:59 -0800 (PST)
In-Reply-To: <4a5881461002250325o45965b2fu2855b712b73e00b9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-25 at 08:25 -0300, Reinaldo de Carvalho wrote:
> Then u32 mask is useless. Or exist a correct mask to match with especific range?

Ranges and masks typically dont mix well generally - this has nothing to
do with u32; try doing subnet ranges for example. It is hard to describe
port range 10->20 using masks..

If i read your email correctly: you are trying to get the first 32 ports
after 6880. It would seem to me the mask should be 0xFFE0, no? i.e your
bc calculation should be:
echo "obase=16;(2^16)-32" | bc

cheers,
jamal

