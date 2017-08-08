From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC 1/1] constify tcp congestion
Date: Tue, 8 Aug 2017 08:18:07 -0700
Message-ID: <20170808081807.573a9c1e@xeon-e3>
References: <20170802024943.7517-1-sthemmin@microsoft.com>
        <20170802024943.7517-2-sthemmin@microsoft.com>
        <1501660563.25002.13.camel@edumazet-glaptop3.roam.corp.google.com>
        <1501661589.25002.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34185 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752062AbdHHPSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 11:18:09 -0400
Received: by mail-pg0-f44.google.com with SMTP id u185so16095961pgb.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 08:18:09 -0700 (PDT)
In-Reply-To: <1501661589.25002.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Aug 2017 01:13:09 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2017-08-02 at 00:56 -0700, Eric Dumazet wrote:
> 
> > Also, I am not convinced this would be a good move, since you added an
> > extra structure which is not const anyway.  
> 
> Actually, this extra structure might be needed if we want to move the
> tcp congestion sysctls to net namespace.
> 
> 
> 


I was thinking about this. It should be possible to have different
list of congestion controls for each net namespace. The list would
be inherited, but each namespace could change:
 	* default CC
	* available CC
	* non-restricted CC
