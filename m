From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] netlink: send exterr cookie on success
Date: Sat, 08 Apr 2017 17:50:03 +0200
Message-ID: <1491666603.5800.22.camel@sipsolutions.net>
References: <20170407194402.4181-1-johannes@sipsolutions.net>
         <20170408112844.3aa4d448@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36246 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751428AbdDHPuK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 11:50:10 -0400
In-Reply-To: <20170408112844.3aa4d448@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 11:28 -0400, Jiri Benc wrote:
> Perhaps the structure should be named just "netlink_ext" or so? It
> seems it'll pick up some non-error related usage, such as the cookies
> here or, in the future, flags indicating how the message should be
> parsed.

Fair point, I'll call it netlink_ext_ack.

johannes
