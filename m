From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: mvm: add const to thermal_cooling_device_ops
 structure
Date: Wed, 28 Jun 2017 14:49:47 +0300
Message-ID: <1498650587.22048.110.camel@coelho.fi>
References: <1498034442-17664-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        linuxwifi@intel.com, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from paleale.coelho.fi ([176.9.41.70]:35590 "EHLO
        farmhouse.coelho.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751554AbdF1LuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 07:50:03 -0400
In-Reply-To: <1498034442-17664-1-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-21 at 14:10 +0530, Bhumika Goyal wrote:
> Declare thermal_cooling_device_ops structure as const as it is only passed
> as an argument to the function thermal_cooling_device_register and this
> argument is of type const. So, declare the structure as const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---

Thanks, we're reviewing this internally.  It looks fine, but I need to
assess whether this will have any impacts in our backports project
before we can apply it.
