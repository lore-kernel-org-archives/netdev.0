From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ip: report IFLA_GSO_MAX_SIZE and
 IFLA_GSO_MAX_SEGS
Date: Thu, 18 Aug 2016 15:14:38 -0700
Message-ID: <1471558478.29842.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471469961.29842.42.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160818145251.784f11d5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35249 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752903AbcHSCcO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:32:14 -0400
Received: by mail-pf0-f193.google.com with SMTP id h186so657159pfg.2
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:32:13 -0700 (PDT)
In-Reply-To: <20160818145251.784f11d5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-18 at 14:52 -0700, Stephen Hemminger wrote:
> On Wed, 17 Aug 2016 14:39:21 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > kernel support for these attributes was added in linux-4.6
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> 
> What about setting them?

This is not something the kernel does at this moment.

Drivers usually set a value, depending on hardware or software
constraints.
