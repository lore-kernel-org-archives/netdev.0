From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 net-next] tuntap: convert to 64-bit interface
 statistics
Date: Thu, 19 Mar 2015 15:56:04 -0700
Message-ID: <1426805764.25985.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426794689-29943-1-git-send-email-jtoppins@cumulusnetworks.com>
	 <1426801109.25985.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <550B4619.6020203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Curt Brune <curt@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:33006 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbbCSW4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 18:56:03 -0400
Received: by iecvj10 with SMTP id vj10so79771338iec.0
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 15:56:03 -0700 (PDT)
In-Reply-To: <550B4619.6020203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-19 at 17:56 -0400, Jonathan Toppins wrote:


> Or are you suggesting per-cpu counters would be preferred which would 
> possibly eliminate the need for this lock?

Might be overkill for a device that is probably used by one cpu,
considering you defined a full  struct rtnl_link_stats64, instead of the
fields that are really handled. 
