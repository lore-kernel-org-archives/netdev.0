From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: MTU of bridge after deleting an interface
Date: Thu, 12 Mar 2015 15:37:31 -0700 (PDT)
Message-ID: <ebf95dd7-9166-43d5-9919-22f2cd654ef6@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33574 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbbCLWhe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:37:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,

When adding an interface the bridge interface's MTU is set to the
minimum of all the interfaces. Call to dev_set_mtu(br->dev, br_min_mtu(br))
in br_add_if() achieves that. But when deleting an interface from the bridge
the MTU is not reset again to the minimum of the current set of interfaces.
Is there a reason it is that way ?

If not I could send a patch that resets the MTU with a call to
dev_set_mtu(br->dev, br_min_mtu(br)) in br_del_if().

Looking forward to your response.

Thanks.

Venkat
