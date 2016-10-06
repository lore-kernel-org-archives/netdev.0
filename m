From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Thu, 06 Oct 2016 04:38:49 -0700
Message-ID: <1475753929.1914.2.camel@perches.com>
References: <20161003085640.GA8130@amd>
         <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
         <1475689996.6105.11.camel@perches.com> <20161005191103.GA25972@amd>
         <1475694934.1941.1.camel@perches.com>
         <063D6719AE5E284EB5DD2968C1650D6DB01E3EAB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
        "trivial@kernel.org" <trivial@kernel.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>, Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0118.hostedemail.com ([216.40.44.118]:44674 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752858AbcJFLiy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 07:38:54 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB01E3EAB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-06 at 09:41 +0000, David Laight wrote:
> From: Joe Perches
> > No worries, and bool is the same ,size as u8.
> That is not guaranteed at all.
> One of the ARM ABI defined bool to be the size of int.

Really?  What kernel has sizeof(_Bool) != 1 ?
