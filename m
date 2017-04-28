From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH iproute2] routel: fix infinite loop in line parser
Date: Fri, 28 Apr 2017 18:21:32 +0200
Message-ID: <20170428162132.GC12806@unicorn.suse.cz>
References: <20170427094347.3EB63A0F1C@unicorn.suse.cz>
 <20170427164647.3f0e09bf@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43439 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S939743AbdD1QVe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 12:21:34 -0400
Content-Disposition: inline
In-Reply-To: <20170427164647.3f0e09bf@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 04:46:47PM -0700, Stephen Hemminger wrote:
> 
> Appled, but this really needs to be done better.
> Either as a simplified output of route command. See ip -br link
> Or ip route should have a json output option and use python/perl/xss
> to reformat.

Agreed, parsing the output of ip command is certainly not the right way.

I must admit that I had no idea this script exists until the bug report
landed on my table (and I had to use "rpm -qf" to learn that it's part
of iproute2 package). And I suspect I may not be the only one.

Michal Kubecek
