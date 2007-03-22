From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: L2TP support?
Date: Thu, 22 Mar 2007 18:33:33 +0100
Message-ID: <200703221833.33530.netdev@axxeo.de>
References: <4602AA25.6020001@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from secondary.axxeo.de ([194.45.45.5]:50393 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934160AbXCVRqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 13:46:12 -0400
In-Reply-To: <4602AA25.6020001@katalix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

James Chapman schrieb:
> Is there interest in adding L2TP support?

Yes, if there is also a user space part somewhere.
 
> I have a patch which could be submitted for review. The PPPoL2TP driver
> presents a PPPoX socket to userspace pppd in the same way as the PPPoE
> and PPPoATM drivers. The kernel handles all data traffic, while
> userspace daemons do L2TP and PPP control message processing.

Like the pppoe-plugin for pppd? 

> In that thread, I was asked to improve the scalability of my solution by
> avoiding the socket-per-session usage imposed by the PPPoX model. 

Since that is imposed by your generic upper layer (PPPoX) this is no valid
argument against your code. (Yes, I've read that thread :-))

> Shall I post the patch?

Yes, please check your patch using the nice checklist in 
Documentation/SubmitChecklist and do it in suitable chunks 
according to Documentation/SubmittingPatches

I'm looking forward to review it!

Best Regards

Ingo Oeser
