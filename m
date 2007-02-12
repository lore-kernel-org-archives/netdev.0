From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: PROBLEM: xt_state compiles without errors but cannot be loaded
Date: Mon, 12 Feb 2007 21:23:37 +0100
Message-ID: <45D0CCC9.30404@trash.net>
References: <20070212121241.36a15c4d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Administrative Services <admin@connectyourweb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49914 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965375AbXBLUXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:23:40 -0500
In-Reply-To: <20070212121241.36a15c4d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> 
> Begin forwarded message:
> 
> Date: Fri, 9 Feb 2007 16:00:50 -0800 (PST)
> From: "Administrative Services" <admin@connectyourweb.com>
> To: linux-kernel@vger.kernel.org
> Subject: PROBLEM: xt_state compiles without errors but cannot be loaded
> 
> 
> [1.] module: xt_state compiles without errors but cannot be loaded
> 
> [2.] Here's what shows up in /var/log/messages:
> 
> kernel: xt_state: Unknown symbol nf_conntrack_untracked
> 
> kernel: xt_state: Unknown symbol nf_ct_l3proto_module_put
> 
> kernel: xt_state: disagrees about version of symbol xt_unregister_matches
> 
> kernel: xt_state: Unknown symbol xt_unregister_matches
> 
> kernel: xt_state: Unknown symbol nf_ct_l3proto_try_module_get
> 
> kernel: xt_state: disagrees about version of symbol xt_register_matches
> 
> kernel: xt_state: Unknown symbol xt_register_matches
> 
> 
> [8.1.] apf 0.9.6 (modified to use xt_state), and insmod


insmod doesn't resolve dependencies, try using modprobe.
