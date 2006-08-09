From: Steven Whitehouse <steve@chygwyn.com>
Subject: Rules and groups
Date: Wed, 9 Aug 2006 09:01:39 +0100
Message-ID: <20060809080139.GA19555@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick Caulfield <patrick@tykepenguin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from souterrain.chygwyn.com ([194.39.143.233]:20904 "EHLO
	souterrain.chygwyn.com") by vger.kernel.org with ESMTP
	id S1030439AbWHIH5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:57:34 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

With your new protocol independent rules code, I see that there is an
entry in struct fib_rules_ops for a netlink group for notification of
rule changes. For whatever reason (historical I guess) DECnet has never
had a nl group assigned for this, so I'm left with two choices when moving
the code over to ues your new scheme.

Either I could send a patch to put the content of notify_rule_change()
conditional on nlgroup being non-zero, or I could assign a suitable
group for DECnet rule changes. I'm leaning towards the latter as the
best solution, so that at least it matches up with the other protocols.

Is there anything to stop me using RTNLGRP_NOP3 for that? (suitable renamed
of course!) So far as I can see its never been assigned to anything else...

Steve.

