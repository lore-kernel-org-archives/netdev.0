From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] ip route: check ftell, fseek return value
Date: Tue, 6 Sep 2016 12:05:14 +0200
Message-ID: <20160906100514.GH29816@orbyte.nwl.cc>
References: <1473143990-9291-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42489 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934086AbcIFKFR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 06:05:17 -0400
Content-Disposition: inline
In-Reply-To: <1473143990-9291-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 02:39:50PM +0800, Hangbin Liu wrote:
> ftell() may return -1 in error case, which is not handled and therefore pass a
> negative offset to fseek(). The return code of fseek() is also not checked.
> 
> Reported-by: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Acked-by: Phil Sutter <phil@nwl.cc>
