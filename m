From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: reflect the fwmark for replies with no socket
Date: Thu, 3 Apr 2014 17:55:51 +0900
Message-ID: <CAKD1Yr1nGPY131oDrHHHNyhatE3nHFA+Tb4QfVv-mTTHY7B=Yw@mail.gmail.com>
References: <1394536541-25702-1-git-send-email-lorenzo@google.com>
 <alpine.LFD.2.11.1403112242190.1769@ja.home.ssi.bg> <CAKD1Yr0WAZaUgtDS2CpiNZsB48U6mT9vd+NniV4jrVTB5DhrQg@mail.gmail.com>
 <alpine.LFD.2.11.1403120857160.1504@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:46322 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162526AbaDCI4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 04:56:12 -0400
Received: by mail-ie0-f169.google.com with SMTP id to1so1509376ieb.14
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 01:56:11 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1403120857160.1504@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 5:22 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         sysctl looks better to me. For example,
> ip_reply_fwmark(net, fwmark) that will return 0 or
> fwmark depending on net->ipv4.sysctl_reply_fwmark boolean.
> Similar for ip6_reply_fwmark() and net->ipv6.sysctl_reply_fwmark.
> You can select the right names.

Ack. I'll shortly post a patch that does this. It uses one
per-namespace sysctl - net.ipv4.fwmark_reflect - for both IPv4 and
IPv6. Using only one sysctl is consistent with things like ping and
tcp, and it marginally shortens the code, but I can change this to two
if desired.
