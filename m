From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC 0/1] tcp: constify congestion_ops
Date: Wed, 2 Aug 2017 08:00:24 +0200
Message-ID: <20170802060024.GB15325@breakpoint.cc>
References: <20170802024943.7517-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58940 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751112AbdHBGCX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 02:02:23 -0400
Content-Disposition: inline
In-Reply-To: <20170802024943.7517-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote:
> I wonder if restricting congestion control choices is still necessary?
> It seems like being overly paranoid, and better enforced by having a more
> limited kernel config, seccomp or other mechanism.

Agree, I think it can be removed.
