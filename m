From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 10/12] forcedeth: add pci_enable_device() to nv_resume()
Date: Sat, 13 Sep 2008 20:08:31 -0400
Message-ID: <48CC55FF.4050300@garzik.org>
References: <200808202352.m7KNq6As006059@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon@fire.lp0.eu, aabdulla@nvidia.com,
	jgarzik@redhat.com, ranma+kernel@tdiedrich.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37475 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180AbYINAIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 20:08:36 -0400
In-Reply-To: <200808202352.m7KNq6As006059@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Simon Arlott <simon@fire.lp0.eu>
> 
> My NIC stops working after resuming from standby, it's not receiving any
> interrupts.
> 
> Commit 25d90810ff49d2a63475776f24c74c6bb49b045f ([netdrvr] forcedeth:
> reorder suspend/resume code) introduces pci_disable_device to nv_suspend,
> but there's no corresponding pci_enable_device in nv_resume - so I added
> one (copied from e1000).  This results in interrupts being re-enabled
> after suspend.
> 
> However, the NIC (10de:0373) still doesn't work after resume.

So... the NIC doesn't work after resume, even after your patch is applied?


