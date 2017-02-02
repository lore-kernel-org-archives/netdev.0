From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Thu, 02 Feb 2017 04:32:13 -0800
Message-ID: <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170202115240.GH17590@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35470 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751511AbdBBMcP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 07:32:15 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so1420848pfa.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 04:32:15 -0800 (PST)
In-Reply-To: <20170202115240.GH17590@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 12:52 +0100, Markus Trippelsdorf wrote:
> Hi,
> 
> from time to time I see the following warning in my kernel log:
> 
>  TCP: eth0: Driver has suspect GRO implementation, TCP performance may be compromised.
> 
> This happens although I run "/usr/sbin/ethtool -K eth0 gro off" in my
> local boot script. 
> What is the warning trying to tell me?
> 

Please report

ethtool -i eth0
