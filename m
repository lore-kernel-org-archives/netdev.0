From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: remove useless check in napi_gro_frags()
Date: Thu, 19 Nov 2015 13:43:45 -0800
Message-ID: <1447969425.22599.254.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447962170.22599.240.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151119195419.GA6728@ast-mbp.thefacebook.com>
	 <1447964139.22599.246.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87oaepzqq2.fsf@nemi.mork.no>
	 <1447965199.22599.252.camel@edumazet-glaptop2.roam.corp.google.com>
	 <f7tfv01pulb.fsf@aconole.bos.csb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Aaron Conole <aconole@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36058 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759150AbbKSVnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:43:47 -0500
Received: by pacdm15 with SMTP id dm15so93223960pac.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 13:43:47 -0800 (PST)
In-Reply-To: <f7tfv01pulb.fsf@aconole.bos.csb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 16:06 -0500, Aaron Conole wrote:

> >
> 
> Would the following be an appropriate change in addition to the one
> you've posted, then? If so I can repost as a formal patch, if you'd
> like. At present, there's only one user of napi_frags_skb(), and your
> patch removes the NULL check. If this can really only be the result of
> buggy driver, then perhaps we should just call out the bug?

Lets mark my patch as "premature" optimization, and revisit whole thing
after audit of the 10 drivers using this interface ;)

Thanks.
