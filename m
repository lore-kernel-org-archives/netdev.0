From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Tue, 20 Oct 2009 09:26:44 -0700
Message-ID: <4ADDE4C4.5080501@hp.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:33074 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbZJTQ0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 12:26:43 -0400
In-Reply-To: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef wrote:
> Turn the global sysctls allowing disabling of TCP SACK, DSCAK,
> time stamp and window scale into per route entry feature options,
> laying the ground to future removal of the relevant global sysctls.
> 
> You really only want to disable SACK, DSACK, time stamp or window
> scale if you've got a piece of broken networking equipment somewhere 
> as a stop gap until you can bring a big enough hammer to deal with
> the broken network equipment. It doesn't make sense to "punish" the
> entire connections going through the machine to destinations not 
> related to the broken equipment.

Is it really only the case that those options get disabled for broken networking 
equipment?  Does this presage making all TCP options per-route only?

rick jones
