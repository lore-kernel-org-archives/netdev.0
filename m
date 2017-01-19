From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 net-next V2] tc: flower: Refactor matching
 flags to be more user friendly
Date: Thu, 19 Jan 2017 15:04:47 +0100
Message-ID: <20170119150447.6b9ad397@griffin>
References: <1484828277-29178-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35650 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753100AbdASO7N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 09:59:13 -0500
In-Reply-To: <1484828277-29178-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 14:17:57 +0200, Paul Blakey wrote:
> Instead of "magic numbers" we can now specify each flag
> by name. Prefix of "no_"  (e.g no_frag) unsets the flag,
> otherwise it wil be set.

Other parts of the tc tool use the "no" prefix (without the
underscore), such as "nofrag" in u32 and pedit, "noecn" in fq_codel and
pie, etc. We should follow the suit here.

Looks good to me otherwise, thanks a lot for doing the work!

 Jiri
