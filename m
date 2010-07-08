From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-2.6 2010-07-08
Date: Thu, 08 Jul 2010 15:46:37 -0700 (PDT)
Message-ID: <20100708.154637.71104736.davem@davemloft.net>
References: <cover.1278619047.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41943
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756211Ab0GHWqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 18:46:23 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu,  8 Jul 2010 16:59:49 -0300

> these patches fix a few bugs and crashes and also two security related
> issues with the authentication procedure.

13 changes is too much this late in the -RC series.  Fixes need to
trickle in, in small quantities, and therefore it's critical that
maintainers submit fixes often and as soon as they are ready.

Please pick a small number of the most critical fixes, say 3 or 4.  An
easy way to roughly quantify which ones shoule be included is:

1) Is there an OOPS or crash regression reported by real users and
   listed in the official lkml regression list which is caused by this
   problem?

2) Is there an exploitable security concern fixed by this change?

Else, it's only net-next-2.6 material.

For example:

    Bluetooth: Remove max_tx and tx_window module paramenters from L2CAP

Things like that change are absolutely not appropriate at this
stage in the post merge-window development environment.

Thanks.
