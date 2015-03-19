From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 net-next] tuntap: convert to 64-bit interface
 statistics
Date: Thu, 19 Mar 2015 16:57:36 -0700
Message-ID: <1426809456.25985.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426794689-29943-1-git-send-email-jtoppins@cumulusnetworks.com>
	 <1426801109.25985.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <550B4619.6020203@cumulusnetworks.com>
	 <1426805764.25985.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Curt Brune <curt@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:36065 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbbCSX5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 19:57:35 -0400
Received: by iedm5 with SMTP id m5so16134332ied.3
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 16:57:34 -0700 (PDT)
In-Reply-To: <1426805764.25985.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-19 at 15:56 -0700, Eric Dumazet wrote:
> On Thu, 2015-03-19 at 17:56 -0400, Jonathan Toppins wrote:
> 
> 
> > Or are you suggesting per-cpu counters would be preferred which would 
> > possibly eliminate the need for this lock?
> 
> Might be overkill for a device that is probably used by one cpu,
> considering you defined a full  struct rtnl_link_stats64, instead of the
> fields that are really handled. 

Note that xmit is already protected by a spinlock (transmit queue lock)
