From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v4 1/2] fix return of iptunnel_xmit
Date: Fri, 9 Oct 2015 16:05:22 +0300
Message-ID: <5617BB92.8000500@cogentembedded.com>
References: <1444382858-6725-1-git-send-email-aschultz@tpip.net>
 <1444382858-6725-2-git-send-email-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Schultz <aschultz@tpip.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:35819 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346AbbJINFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 09:05:24 -0400
Received: by lbwr8 with SMTP id r8so79493510lbw.2
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 06:05:23 -0700 (PDT)
In-Reply-To: <1444382858-6725-2-git-send-email-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/9/2015 12:27 PM, Andreas Schultz wrote:

> All users of iptunnel_xmit expect the return value to be the packet
> length on success (>0), negative for a tx error and zero for a tx
> dropped error. In cset 0e6fbc5b6c6218987c93b8c7ca60cf786062899d the

    Didn't checkpatch.pl compalin about improper commit citing?

> negative return case was lost.

> This bug was introduced when the ip_tunnel_core code was refactored.

> Fixes: 0e6fbc5b6c6218987c93b8c7ca60cf786062899d

    See Documentation/SubmittingPatches for the proper format of this tag.

> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> Acked-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

MBR, Sergei
