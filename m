From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net] libceph: osdmap: Fix some NULL dereferences
Date: Thu, 13 Jul 2017 23:23:22 +0300
Message-ID: <20170713202322.4joas52vuvjpx6w5@mwanda>
References: <20170713074517.io64uezw3qf6oush@mwanda>
 <CAOi1vP8tNXb7izDJXV1LzHhFMcqhFh_+_+zxsHQZnqgb_S+Etg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ceph Development <ceph-devel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org
To: Ilya Dryomov <idryomov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30403 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752745AbdGMUXk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 16:23:40 -0400
Content-Disposition: inline
In-Reply-To: <CAOi1vP8tNXb7izDJXV1LzHhFMcqhFh_+_+zxsHQZnqgb_S+Etg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 13, 2017 at 06:13:22PM +0200, Ilya Dryomov wrote:
> 
> Hi Dan,
> 
> I applied osdmap_apply_incremental() hunk and fixed a similar bug in
> osdmap_decode() (it's a not NULL deref, that's why smatch didn't catch
> it).
> 

No...  :/  Smatch complained about it, but I somehow marked it as done
yesterday without sending a patch.  Thanks for catching that.

The Smatch check is just looking for places where we do ERR_PTR(0) or
ERR_PTR(valid_ptr).  That can be intentional, so there is some hand
reviewing involved.

regards,
dan carpenter
