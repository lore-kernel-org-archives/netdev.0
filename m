From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix for vf mac addr command sent to
 nic firmware
Date: Tue, 21 Mar 2017 17:48:39 -0700 (PDT)
Message-ID: <20170321.174839.705889972695947836.davem@davemloft.net>
References: <20170317224326.GA2409@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933142AbdCVAsl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 20:48:41 -0400
In-Reply-To: <20170317224326.GA2409@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 17 Mar 2017 15:43:26 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> Change to support host<->firmware command return value.
> Fix for vf mac addr state command.
> 1. Added support for firmware commands to return a value:
>    - previously, the returned code overlapped with host codes, thus
>      commands were only returning 0 (success) or -1 (interpreted as
>      timeout)
>    - per 'response_manager.h', the error codes are split into two fields
>      (major/minor) now, firmware commands are grouped into their own
>      'major' group, separate from the host's 'major' group, which allow f/w
>      commands to return any 16-bit value
> 2. The command to set vf mac addr was logging a success message even if
>    command failed.  Now command uses a callback function to log the status
>    message.
> 3. The command to set vf mac addr was not logging a message when set via
>    the host 'ip' command.  Now, the callback function will log an
>    appropriate message.
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied, thanks.
