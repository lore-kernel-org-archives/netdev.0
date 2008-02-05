From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [patch 2/4] forcedeth: fix MAC address detection on network card
 (regression in 2.6.23)
Date: Tue, 05 Feb 2008 10:38:56 -0800
Message-ID: <47A8AD40.7010007@zytor.com>
References: <200802050746.m157ktY9010399@imap1.linux-foundation.org> <47A8A90B.6010602@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	michael.pyne@kdemail.net, AAbdulla@nvidia.com,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:58729 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230AbYBESj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 13:39:27 -0500
In-Reply-To: <47A8A90B.6010602@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
>>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> NAK - this fixes one set of users, and breaks a working set of users.
> 
> Need to add DMI check for the specific motherboard (dmi_check_system), 
> and flip flag according to success/failure of that check.
> 

Either that, or detect the Gigabyte prefix used as a suffix, since they 
seem to be the source of this particular f*ckup.

	-hpa
