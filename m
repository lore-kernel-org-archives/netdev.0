From: Jiri Kosina <jikos@kernel.org>
Subject: Re: kernel panic in qdisc_match_from_root starting openvswitch
Date: Tue, 16 Aug 2016 21:18:37 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608162115510.22028@cbobk.fhfr.pm>
References: <bfb76544-6d3a-dcd4-9338-72ecfda9f691@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56797 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751953AbcHPTdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 15:33:46 -0400
In-Reply-To: <bfb76544-6d3a-dcd4-9338-72ecfda9f691@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Aug 2016, David Ahern wrote:

> Jiri:
> 
> I am hitting a kernel panic with '/etc/init.d/openvswitch-switch 
> restart' Stack trace below. Reverting 59cc1f61f09c ("net: sched: convert 
> qdisc linked list to hashtable") clears the problem.

Thanks a lot for the report. Could you please test either with the 
attached two patches applied on top of net-next, or alternatively with 
'might-rebase/net-sched-qdiscs' branch of

	git://git.kernel.org/pub/scm/linux/kernel/git/jikos/jikos.git

(HEAD of that branch is 60b3487ad7f) and report back to me whether it 
fixes any issues you are seeing? Applying the attached patches on top of 
net-next or testing with the git branch above should be equivalent test 
wrt. qdiscs.

Thanks,

-- 
Jiri Kosina
SUSE Labs
