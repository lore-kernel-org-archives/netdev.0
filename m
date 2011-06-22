From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 08:29:11 -0700
Message-ID: <m2k4cd3mwo.fsf@firstfloor.org>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, agospoda@redhat.com,
	nhorman@redhat.com, lwoodman@redhat.com
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6596 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932384Ab1FVPan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 11:30:43 -0400
In-Reply-To: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
	(Prarit Bhargava's message of "Tue, 21 Jun 2011 09:00:40 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prarit Bhargava <prarit@redhat.com> writes:
>
> Note that the network sysrq automatically disables after the receipt of
> the ping, ie) it is single-shot mode.  If you want to use this again, you
> must complete the above four steps again.
 
Good idea, but: why not add a single key (e.g. a hash digest with 
the key hashed in) and make it reasonably secure?  
That should not be that hard and would make it a lot more useful.

It would not defend against all attacks, but probably make it
"LAN grade" at least.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
