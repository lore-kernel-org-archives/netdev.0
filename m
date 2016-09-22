From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] misc/ss: tcp cwnd should be unsigned
Date: Thu, 22 Sep 2016 10:48:20 +0200
Message-ID: <20160922084820.GB22100@orbyte.nwl.cc>
References: <1474533628-5784-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42114 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756117AbcIVIsW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 04:48:22 -0400
Content-Disposition: inline
In-Reply-To: <1474533628-5784-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2016 at 04:40:28PM +0800, Hangbin Liu wrote:
> tcp->snd_cwd is a u32, but ss treats it like a signed int. This may
> results in negative bandwidth calculations.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Acked-by: Phil Sutter <phil@nwl.cc>
