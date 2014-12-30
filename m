From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 30 Dec 2014 10:16:57 -0800
Message-ID: <CAL3LdT73zfJwNcHS0ZpZ=ZzG=UiCUW5UEnOF9Fp2rR0e-ejXYg@mail.gmail.com>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:65467 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaL3SQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 13:16:57 -0500
Received: by mail-oi0-f43.google.com with SMTP id i138so28744052oig.2
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 10:16:57 -0800 (PST)
In-Reply-To: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
<vladz@cloudius-systems.com> wrote:
> Add the ethtool ops to VF driver to allow querying the RSS indirection table
> and RSS Random Key.
>
>  - PF driver: Add new VF-PF channel commands.
>  - VF driver: Utilize these new commands and add the corresponding
>               ethtool callbacks.
>
> Vlad Zolotarov (5):
>   ixgbe: Add a RETA query command to VF-PF channel API
>   ixgbevf: Add a RETA query code
>   ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
>   ixgbevf: Add RSS Key query code
>   ixgbevf: Add the appropriate ethtool ops to query RSS indirection
>     table and key
>
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   8 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  60 +++++++++++
>  drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  37 +++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |   8 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 125 ++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
>  7 files changed, 243 insertions(+), 1 deletion(-)

Remember to CC on patches against drivers in drivers/net/ethernet/intel/ please.


-- 
Cheers,
Jeff
