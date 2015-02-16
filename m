From: David Ahern <dsahern@gmail.com>
Subject: Re: vnet problem (bug? feature?)
Date: Mon, 16 Feb 2015 08:30:12 -0700
Message-ID: <54E20D04.8050409@gmail.com>
References: <20150213114113.GA10559@faui40p.informatik.uni-erlangen.de> <CAHA+R7NUojPsLY9LOC94S0uussbwKsGRdcbazNmGGLbXvxCk-A@mail.gmail.com> <20150214101547.GA9335@faui40p.informatik.uni-erlangen.de> <20150214131744.051b90fc8dfdbf4e1bfe6bfb@mindspring.com> <20150215190008.GA25792@faui40p.informatik.uni-erlangen.de> <CACP96tRBPy4cakmJY_K9zrYbgWLgNfxDo4inrH8qV6pgRtR-1g@mail.gmail.com> <20150216101309.GB25792@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>
To: Toerless Eckert <tte@cs.fau.de>,
	Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:45639 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbbBPPaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 10:30:20 -0500
Received: by iecat20 with SMTP id at20so34584255iec.12
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 07:30:19 -0800 (PST)
In-Reply-To: <20150216101309.GB25792@faui40p.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/15 3:13 AM, Toerless Eckert wrote:
> I fail to find a good reference explaining why linux would default to
> rp_filtering = 1 (more appropriate for routers) even if forwarding defaults to 0
> (more appropriate for multi-homed hosts).

It's a userspace default. For Fedora/Red Hat based systems see 
/etc/sysctl.conf (older releases) and /usr/lib/sysctl.d/50-default.conf 
(newer ones).

I recall it defaulting to 1 in the early 2000's so it has been that way 
for a long time.

 From Documentation/networking/ip-sysctl.txt:

rp_filter - INTEGER
...
         Default value is 0. Note that some distributions enable it
         in startup scripts.

David
