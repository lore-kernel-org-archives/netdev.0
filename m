From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Thu, 19 Oct 2017 13:39:49 -0700
Message-ID: <20171019203949.pyv44i5sy6lnuavh@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170918080214.yrejz67wwnp2pjzf@localhost>
 <87k20vip3f.fsf@intel.com>
 <20170919052244.77umdxuze53t6j22@localhost>
 <87wp4ufchl.fsf@intel.com>
 <20170920052558.h6c4lkqmzk2h2pdq@localhost>
 <62f3eae4-bf6a-1475-936f-5011c9ff381e@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com, Levi Pearson <levipearson@gmail.com>,
        Henrik Austad <henrik@austad.us>
To: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:54229 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751855AbdJSUjx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 16:39:53 -0400
Received: by mail-pf0-f182.google.com with SMTP id t188so7677610pfd.10
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 13:39:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <62f3eae4-bf6a-1475-936f-5011c9ff381e@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 03:37:35PM -0700, Jesus Sanchez-Palencia wrote:
> I also did some tests with when you don't set valid launch times, but here using
> your idea from above, so with the driver calculating a valid launch time (i.e.
> current NIC time + X ns, varying X across tests) for packets that didn't have it
> set by the user, and I wasn't too happy with its reliability. It could
> definitely be improved, but it has left me wondering: instead, what about
> documenting that if you enable TXTIME, then you *must* provide a valid Launch
> time for all packets on traffic classes that are affected?

If txtime is enabled, then CBS is pointless because the txtime already
specifies the bandwidth implicitly.

The problem is when one program uses txtime and another uses CBS, then
the CBS user will experience really wrong performance.

Thanks,
Richard
