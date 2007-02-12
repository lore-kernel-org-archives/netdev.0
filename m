From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: PROBLEM: xt_state compiles without errors but cannot be loaded
Date: Mon, 12 Feb 2007 12:12:41 -0800
Message-ID: <20070212121241.36a15c4d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Administrative Services" <admin@connectyourweb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40860 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964827AbXBLUM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 15:12:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 9 Feb 2007 16:00:50 -0800 (PST)
From: "Administrative Services" <admin@connectyourweb.com>
To: linux-kernel@vger.kernel.org
Subject: PROBLEM: xt_state compiles without errors but cannot be loaded


[1.] module: xt_state compiles without errors but cannot be loaded

[2.] Here's what shows up in /var/log/messages:

kernel: xt_state: Unknown symbol nf_conntrack_untracked

kernel: xt_state: Unknown symbol nf_ct_l3proto_module_put

kernel: xt_state: disagrees about version of symbol xt_unregister_matches

kernel: xt_state: Unknown symbol xt_unregister_matches

kernel: xt_state: Unknown symbol nf_ct_l3proto_try_module_get

kernel: xt_state: disagrees about version of symbol xt_register_matches

kernel: xt_state: Unknown symbol xt_register_matches


[3.] modules, netfilter:

[4.] 2.6.20:

[5.] 2.6.19.2 possibly 2.6.9.3:

[7.] try loading module using insmod

[8.] CentOS 4.4
[8.1.] apf 0.9.6 (modified to use xt_state), and insmod

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
