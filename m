From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [V2 PATCH 0/9] vhost/macvtap zeropcopy fixes
Date: Wed, 02 May 2012 12:40:55 -0700
Message-ID: <87pqammkvs.fsf@xmission.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120502055008.GA29319@redhat.com>
	<20120502.024427.22049954455309204.davem@davemloft.net>
	<20120502081141.GA30549@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jasowang@redhat.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41732 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756138Ab2EBTlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 15:41:04 -0400
In-Reply-To: <20120502081141.GA30549@redhat.com> (Michael S. Tsirkin's message
	of "Wed, 2 May 2012 11:11:43 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Side question.  Are you aware that macvtap/vhost net is broken
in the presence of  vlan accelleration and that vlan accelleration
is not optional if you are using vlan headers?

Eric
