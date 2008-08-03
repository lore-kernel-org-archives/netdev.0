From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: Re: Fw: dev_queue_xmit() to now non-existing device (text wrapped
 now)
Date: Mon, 4 Aug 2008 06:41:58 +0930
Message-ID: <20080804064158.393f9608.ipng@69706e6720323030352d30312d31340a.nosense.org>
References: <20080803083248.0b9dc284.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mistral.mail.adnap.net.au ([203.6.132.90]:53475 "EHLO
	mistral.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756521AbYHCVLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 17:11:35 -0400
Received: from 114-30-101-60.ip.adam.com.au ([114.30.101.60] helo=mail.nosense.org)
	by mistral.mail.adnap.net.au with esmtp (Exim 4.69 (FreeBSD))
	(envelope-from <ipng@69706e6720323030352d30312d31340a.nosense.org>)
	id 1KPkxl-000L2i-9p
	for netdev@vger.kernel.org; Mon, 04 Aug 2008 06:48:01 +0930
In-Reply-To: <20080803083248.0b9dc284.ipng@69706e6720323030352d30312d31340a.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 3 Aug 2008 08:32:48 +0930
Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org> wrote:

> A mail client upgrade must have dropped that setting :-|
> 
> Begin forwarded message:
> 
> Date: Sat, 2 Aug 2008 21:38:28 +0930
> From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
> To: netdev@vger.kernel.org
> Subject: dev_queue_xmit() to now non-existing device
> 
> 
> Hi,
> 
<snip>

> Has anybody got any suggestions or pointers to where this problem has
> been solved? 
> 

I've now discovered dev_hold() and dev_put(), and the requirement
to use them to register / deregister which interfaces my protocol
is using. I think has now solved my problem. Sorry for the noise.

Thanks,
Mark.

