From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] htb: add support for direct_qlen attribute
Date: Fri, 13 Sep 2013 09:06:15 -0700
Message-ID: <1379088375.24408.43.camel@edumazet-glaptop>
References: <1379086235.24408.41.camel@edumazet-glaptop>
	 <1379086427.24408.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36037 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab3IMQGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 12:06:18 -0400
Received: by mail-pa0-f53.google.com with SMTP id lb1so2691621pab.40
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 09:06:17 -0700 (PDT)
In-Reply-To: <1379086427.24408.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-13 at 08:33 -0700, Eric Dumazet wrote:
> On Fri, 2013-09-13 at 08:30 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > TCA_HTB_DIRECT_QLEN attribute is supported since linux-3.10
> > 
> > HTB classes use an internal pfifo queue, which limit was not reported
> 
> s/classes/qdisc/

I'll send a new version, help should go in explain1()
