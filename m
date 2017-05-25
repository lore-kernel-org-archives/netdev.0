From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Enable TSO support
Date: Thu, 25 May 2017 14:46:26 -0400 (EDT)
Message-ID: <20170525.144626.1787511445330790842.davem@davemloft.net>
References: <1495679366-7149-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765858AbdEYSq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 14:46:28 -0400
In-Reply-To: <1495679366-7149-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 24 May 2017 21:29:26 -0500

> The feature is also enabled by a module parameter.
> This parameter is necessary because TSO can not easily be
> enabled or disabled in firmware without reinitializing the driver.

Sorry, this is unacceptable.  When I say no module parameters,
I really really mean it.

Users should not be burdoned with having to know a special knob for
every driver in order to adjust what is a generic feature.

You'll have to find another way to accomodate this.
