From: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Subject: Storing hardware timestamps - how about using the new skb's control
 block?
Date: Wed, 12 Nov 2008 07:23:40 +1030
Message-ID: <20081112072340.1c0c1a74.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.mail.adnap.net.au ([203.6.132.66]:56012 "EHLO
	smtp2.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbYKKVzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 16:55:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Just a quick suggestion for storing hardware timestamps, how about
storing them in the new skb's control block?

>From what I understand, any private users of the control block are
supposed to ignore the existing value, and if a protocol/tap is going
to be looking at the new skb, it should have done a skb_share_check()
first to grab it's own private copy if necessary, protecting the
control block stored timestamp value from any of the other skb
users who might change the control block value for their own purposes.

Regards,
Mark.

-- 

        "Sheep are slow and tasty, and therefore must remain constantly
         alert."
                                   - Bruce Schneier, "Beyond Fear"
