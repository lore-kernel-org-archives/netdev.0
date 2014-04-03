From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: reflect the fwmark for replies with no socket
Date: Thu, 3 Apr 2014 18:06:08 +0900
Message-ID: <CAKD1Yr1HFhtgeNS22AKEATvf86UbZ2u+YTXVn_1qCFu1YrH9+g@mail.gmail.com>
References: <1394536541-25702-1-git-send-email-lorenzo@google.com>
 <alpine.LFD.2.11.1403112242190.1769@ja.home.ssi.bg> <CAKD1Yr0WAZaUgtDS2CpiNZsB48U6mT9vd+NniV4jrVTB5DhrQg@mail.gmail.com>
 <alpine.LFD.2.11.1403120857160.1504@ja.home.ssi.bg> <CAKD1Yr1nGPY131oDrHHHNyhatE3nHFA+Tb4QfVv-mTTHY7B=Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:53889 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106AbaDCJG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 05:06:29 -0400
Received: by mail-ie0-f174.google.com with SMTP id rp18so1469981iec.5
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 02:06:28 -0700 (PDT)
In-Reply-To: <CAKD1Yr1nGPY131oDrHHHNyhatE3nHFA+Tb4QfVv-mTTHY7B=Yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 3, 2014 at 5:55 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> Ack. I'll shortly post a patch that does this. It uses one
> per-namespace sysctl - net.ipv4.fwmark_reflect - for both IPv4 and
> IPv6.

http://patchwork.ozlabs.org/patch/336553/

David, does it look better to you now it's an option?
