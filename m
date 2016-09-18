From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] tc: don't accept qdisc 'handle' greater than ffff
Date: Sun, 18 Sep 2016 21:47:12 +0200
Message-ID: <20160918194419.5526D64BDC@mail.nwl.cc>
References: <bdc0d8e58be9344b44fcd64a56b5b62004c108a1.1473930575.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41087 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932228AbcIRToV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 15:44:21 -0400
Content-Disposition: inline
In-Reply-To: <bdc0d8e58be9344b44fcd64a56b5b62004c108a1.1473930575.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 10:30:00AM +0200, Davide Caratti wrote:
> since get_qdisc_handle() truncates the input value to 16 bit, return an
> error and prompt "invalid qdisc ID" in case input 'handle' parameter needs
> more than 16 bit to be stored.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Acked-by: Phil Sutter <phil@nwl.cc>
