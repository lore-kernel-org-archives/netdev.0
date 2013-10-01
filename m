From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: [net-next 3/3] net: ipv4 only populate IP_PKTINFO when needed
Date: Tue, 1 Oct 2013 17:29:25 -0500
Message-ID: <20131001222925.GB8653@sbohrermbp13-local.rgmadvisors.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
 <1380656025-8847-4-git-send-email-sbohrer@rgmadvisors.com>
 <1380660150.19002.34.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:54303 "EHLO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753176Ab3JAWgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 18:36:06 -0400
Received: by mail-oa0-f52.google.com with SMTP id n2so1571oag.25
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 15:36:05 -0700 (PDT)
In-Reply-To: <1380660150.19002.34.camel@edumazet-glaptop.roam.corp.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 01, 2013 at 01:42:30PM -0700, Eric Dumazet wrote:
> On Tue, 2013-10-01 at 14:33 -0500, Shawn Bohrer wrote:
> 
> > -void ipv4_pktinfo_prepare(struct sk_buff *skb)
> > +void ipv4_pktinfo_prepare(struct sock *sk, struct sk_buff *skb)
> 
> 
> Seems good to me, could you use :
> 
> void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)

Yep, I'll make that const and resend.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
