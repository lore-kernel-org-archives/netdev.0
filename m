From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 0/2] Use one func to output stats from Netlink
 and /proc
Date: Tue, 30 Dec 2014 15:58:02 +0200
Message-ID: <20141230135802.GA25940@angus-think.wlc.globallogic.com>
References: <1419897380-21012-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:56116 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbaL3OIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 09:08:23 -0500
Received: by mail-la0-f52.google.com with SMTP id hs14so12808083lab.11
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 06:08:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1419897380-21012-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2014 at 01:56:18AM +0200, Vadim Kochan wrote:
> Refactoring to use one func to output sock stats
> from Netlink and /proc for unix and packet socket types.
> 
> I did some testing but I might miss some cases, would be good if someone
> can test it too.
> 
> Vadim Kochan (2):
>   ss: Unify unix stats output from netlink and proc
>   ss: Unify packet stats output from netlink and proc
> 
>  misc/ss.c | 310 ++++++++++++++++++++++++++------------------------------------
>  1 file changed, 132 insertions(+), 178 deletions(-)
> 
> -- 
> 2.1.3
> 
Please ignore this series as I have one more additional little fix which related to
these changes. The fix is related to issue when filtering does not work
for UNIX sockets when you do:

    # ss -x src *X11*

Seems that the issue was started from:

    (dfbaa90dec) iproute: Dump unix sockets via netlink

where filter was not considered in the netlink handler.

So I will re-send full series with using of filter for netlink diag handler too.

Regards,
