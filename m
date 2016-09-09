From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [iproute PATCH] macsec: fix input range of 'icvlen' parameter
Date: Fri, 9 Sep 2016 17:53:52 +0200
Message-ID: <20160909155352.GA16002@bistromath.localdomain>
References: <b1f730436465e511edb56e4486299e4f3835599b.1473428548.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45592 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753240AbcIIPx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 11:53:56 -0400
Content-Disposition: inline
In-Reply-To: <b1f730436465e511edb56e4486299e4f3835599b.1473428548.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-09, 16:02:22 +0200, Davide Caratti wrote:
> the maximum possible ICV length in a MACsec frame is 16 octects, not 32:
> fix get_icvlen() accordingly, so that a proper error message is displayed
> in case input 'icvlen' is greater than 16.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Acked-by: Sabrina Dubroca <sd@queasysnail.net>

-- 
Sabrina
