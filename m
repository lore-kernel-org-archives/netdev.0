From: Luca Coelho <luca@coelho.fi>
Subject: Re: drivers/net/wireless/intel/iwlwifi/pcie/trans.c: 2 * suspicious
 code ?
Date: Mon, 09 Jan 2017 13:16:23 +0200
Message-ID: <1483960583.5227.24.camel@coelho.fi>
References: <VI1PR08MB1022D85586276BFDE1125B539C630@VI1PR08MB1022.eurprd08.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: David Binderman <dcb314@hotmail.com>,
        "johannes.berg@intel.com" <johannes.berg@intel.com>,
        "emmanuel.grumbach@intel.com" <emmanuel.grumbach@intel.com>,
        "linuxwifi@intel.com" <linuxwifi@intel.com>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from paleale.coelho.fi ([176.9.41.70]:34030 "EHLO
        farmhouse.coelho.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965461AbdAILQa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 06:16:30 -0500
In-Reply-To: <VI1PR08MB1022D85586276BFDE1125B539C630@VI1PR08MB1022.eurprd08.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-06 at 17:47 +0000, David Binderman wrote:
> Hello there,

Hi David,


> 1.
> 
> drivers/net/wireless/intel/iwlwifi/pcie/trans.c:2039:14: warning: decrement of a boolean expression [-Wbool-operation]
> 
> Source code is
> 
>            txq->block--;
> 
> Maybe someone got a bool and a int mixed up ?
> 
> 2.
> 
> drivers/net/wireless/intel/iwlwifi/pcie/trans.c:2045:14: warning: increment of a boolean expression [-Wbool-operation]
> 
> Duplicate a few lines further down.

Emmanuel has fixed this in our internal tree and I'll be sending it out
together with our normal upstreaming process.

Thanks for reporting!
