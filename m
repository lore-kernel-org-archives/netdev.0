From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Fwd: Re: Bug#538372: header failure including netlink.h (or
   uio.h)]
Date: Tue, 29 Sep 2009 21:21:05 +0200
Message-ID: <4AC25E21.7050407@gmail.com>
References: <1254137084.4756.11.camel@ce170155.zmb.uni-duisburg-essen.de> <20090929092727.GA7025@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Manuel Prinz <manuel@debian.org>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:9609 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbZI2TWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 15:22:04 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1171753fge.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 12:22:08 -0700 (PDT)
In-Reply-To: <20090929092727.GA7025@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 09/29/2009 11:27 AM:

> On 28-09-2009 13:24, Manuel Prinz wrote:
>> Hi everyone,
>>
>> I'm forwarding this bug in Debian (http://bugs.debian.org/538372) as
>> requested by the Debian kernel team. A patch is available. Applying just
>> the first hunk fixes the issue for me. I've not enough kernel knowledge
>> to judge if this fix is a proper solution, though.
>>
>> It would be really great if someone could have a look at it. Thanks in
>> advance! (And please CC me in replies. Thanks!)
> 
> I've tried it with current include/linux and it works OK. Replacing
> uio.h on Debian really was not enough, but it looks like missing
> compiler.h entries could be the reason. Otherwise, please send your
> compile error log.
 

Hmm... Probably you noticed it yourself, so a little update for the
record. My method wasn't the proper way, but repeating it with
sanitized headers from the current kernel works even better: replacing
Debian's uio.h only seems to be enough yet.

Jarek P.
