From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add deleted when
 monitoring delmdb event
Date: Fri, 31 Jul 2015 18:15:04 -0700
Message-ID: <20150731181504.46aeea04@urahara>
References: <1438248632-6270-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34620 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbbHABO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 21:14:56 -0400
Received: by pacan13 with SMTP id an13so49818379pac.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 18:14:55 -0700 (PDT)
In-Reply-To: <1438248632-6270-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Jul 2015 11:30:32 +0200
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Before this patch both addmdb and delmdb events were printed the same,
> now we'll get a "Deleted" string in front when delmdb is received.
> Before:
> $ bridge mdb add dev br0 port eth3 grp 239.0.0.1
> (monitor) dev br0 port eth3 grp 239.0.0.1 temp
> $ bridge mdb del dev br0 port eth3 grp 239.0.0.1
> (monitor) dev br0 port eth3 grp 239.0.0.1 temp
> ^^ No way to differentiate between both events.
> 
> After:
> $ bridge mdb add dev br0 port eth3 grp 239.0.0.1
> (monitor) dev br0 port eth3 grp 239.0.0.1 temp
> $ bridge mdb del dev br0 port eth3 grp 239.0.0.1
> (monitor) Deleted dev br0 port eth3 grp 239.0.0.1 temp
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Added to net-next.
