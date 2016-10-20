From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: must lock the socket in udp_disconnect()
Date: Thu, 20 Oct 2016 13:44:39 -0700
Message-ID: <1476996279.7065.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <05f766db-4a8c-933e-9d73-6daada21f491@gmail.com>
         <1476944754.7065.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <1476981580.7065.15.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161020.144610.532749573029633695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sploving1@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35774 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753398AbcJTUok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 16:44:40 -0400
Received: by mail-pf0-f174.google.com with SMTP id s8so43022680pfj.2
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 13:44:40 -0700 (PDT)
In-Reply-To: <20161020.144610.532749573029633695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-20 at 14:46 -0400, David Miller wrote:

> 
> Applied, sounds like I should queue this up for -stable too right?

Yes, I believe all stable versions have this bug.
Thanks.
