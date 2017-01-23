From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/2] vxlan: don't flush static fdb entries on
 admin down
Date: Mon, 23 Jan 2017 09:55:55 +0100
Message-ID: <20170123095555.0778abb6@griffin>
References: <1484984599-16712-1-git-send-email-roopa@cumulusnetworks.com>
        <1484984599-16712-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        ramanb@cumulusnetworks.com, stephen@networkplumber.org,
        pshelar@ovn.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55528 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750840AbdAWI4M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 03:56:12 -0500
In-Reply-To: <1484984599-16712-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2017 23:43:18 -0800, Roopa Prabhu wrote:
> This patch skips flushing static fdb entries in
> ndo_stop, but flushes all fdb entries during vxlan
> device delete. This is consistent with the bridge
> driver fdb

This makes sense but isn't this a uAPI change? Do you know whether
there are users relying on the current behavior?

 Jiri
