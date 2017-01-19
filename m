From: Paul Blakey <paulb@mellanox.com>
Subject: Re: [PATCH iproute2 net-next V2] tc: flower: Refactor matching flags
 to be more user friendly
Date: Thu, 19 Jan 2017 16:14:43 +0200
Message-ID: <aa0ff306-51f4-bacc-203b-e922be105204@mellanox.com>
References: <1484828277-29178-1-git-send-email-paulb@mellanox.com>
 <20170119150447.6b9ad397@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paulb@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0043.outbound.protection.outlook.com ([104.47.1.43]:31680
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752694AbdASOPz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 09:15:55 -0500
In-Reply-To: <20170119150447.6b9ad397@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 19/01/2017 16:04, Jiri Benc wrote:
> On Thu, 19 Jan 2017 14:17:57 +0200, Paul Blakey wrote:
>> Instead of "magic numbers" we can now specify each flag
>> by name. Prefix of "no_"  (e.g no_frag) unsets the flag,
>> otherwise it wil be set.
>
> Other parts of the tc tool use the "no" prefix (without the
> underscore), such as "nofrag" in u32 and pedit, "noecn" in fq_codel and
> pie, etc. We should follow the suit here.
>
> Looks good to me otherwise, thanks a lot for doing the work!
>
>  Jiri
>

Thanks, v3 is up.
