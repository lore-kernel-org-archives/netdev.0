From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [patch 10/12] forcedeth: add pci_enable_device() to nv_resume()
Date: Sun, 14 Sep 2008 13:40:53 +0100
Message-ID: <48CD0655.6050809@simon.arlott.org.uk>
References: <200808202352.m7KNq6As006059@imap1.linux-foundation.org> <48CC55FF.4050300@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	aabdulla@nvidia.com, jgarzik@redhat.com, ranma+kernel@tdiedrich.de
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:47891 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776AbYINMlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Sep 2008 08:41:06 -0400
In-Reply-To: <48CC55FF.4050300@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/09/08 01:08, Jeff Garzik wrote:
> akpm@linux-foundation.org wrote:
>> From: Simon Arlott <simon@fire.lp0.eu>
>> 
>> My NIC stops working after resuming from standby, it's not receiving any
>> interrupts.
>> 
>> Commit 25d90810ff49d2a63475776f24c74c6bb49b045f ([netdrvr] forcedeth:
>> reorder suspend/resume code) introduces pci_disable_device to nv_suspend,
>> but there's no corresponding pci_enable_device in nv_resume - so I added
>> one (copied from e1000).  This results in interrupts being re-enabled
>> after suspend.
>> 
>> However, the NIC (10de:0373) still doesn't work after resume.
> 
> So... the NIC doesn't work after resume, even after your patch is applied?

It works after resume with MSI disabled.

-- 
Simon Arlott
