From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Fix IFE meta modules loading
Date: Thu, 12 Oct 2017 12:23:18 -0700 (PDT)
Message-ID: <20171012.122318.1151617277989957064.davem@davemloft.net>
References: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752942AbdJLTXT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 15:23:19 -0400
In-Reply-To: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Wed, 11 Oct 2017 10:50:28 -0400

> Adjust module alias names of IFE meta modules and fix the bug that
> prevented auto-loading IFE modules in run-time.

Anyone using the existing alises will be broken by these changes
no?

Is it possible to define multiple aliases?  That would be a way to
get the more desirable names whilst not breaking existing users.
