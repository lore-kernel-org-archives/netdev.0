From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] tipc: check return value of nlmsg_new
Date: Sun, 23 Apr 2017 00:17:16 -0700
Message-ID: <1492931836.30293.43.camel@perches.com>
References: <1492931359-25004-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>, Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0217.hostedemail.com ([216.40.44.217]:36090 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1427665AbdDWHRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 03:17:23 -0400
In-Reply-To: <1492931359-25004-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-23 at 15:09 +0800, Pan Bian wrote:
> Function nlmsg_new() will return a NULL pointer if there is no enough
> memory, and its return value should be checked before it is used.
> However, in function tipc_nl_node_get_monitor(), the validation of the
> return value of function nlmsg_new() is missed. This patch fixes the
> bug.

Hello.

Thanks for the patches.

Are you finding these via a tool or inspection?

If a tool is being used, could you please describe it?
