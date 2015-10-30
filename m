From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG in ipmr_queue_xmit()
Date: Fri, 30 Oct 2015 12:12:36 -0700
Message-ID: <1446232356.6254.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.OSX.2.00.1510291646320.59200@animac.local>
	 <20151030001510.GG18062@breakpoint.cc>
	 <alpine.OSX.2.00.1510291841480.68875@animac.local>
	 <1446178542.6254.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151030103658.GA25931@breakpoint.cc>
	 <1446201624.707140.424480297.4D8B55D6@webmail.messagingengine.com>
	 <20151030104846.GA3461@breakpoint.cc>
	 <1446202828.6254.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAOxq_8Nd8KA8CpwVPtCr2gwDbfzsqRp586PddF7r5DSSmeHb6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ani Sinha <ani@anirban.org>, fruggeri <fruggeri@arista.com>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35224 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbJ3TMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 15:12:38 -0400
Received: by pasz6 with SMTP id z6so82222607pas.2
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 12:12:38 -0700 (PDT)
In-Reply-To: <CAOxq_8Nd8KA8CpwVPtCr2gwDbfzsqRp586PddF7r5DSSmeHb6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-30 at 10:47 -0700, Ani Sinha wrote:

> for 32 bit archs, it does in SNMP_ADD_STATS64_USER()

Sure. But x86 these days is 64bit, at 99 % maybe.

We do not make changes that looks 'maybe better' for i486 or i586

Just do the same that multiple similar patches did.

Example :

757efd32d5ce31f67193cc0e6a56e4dffcc42fb1

Thanks.
