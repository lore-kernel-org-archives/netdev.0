From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 1/1] NET: ipv6, fix potential null dereference
Date: Sun, 10 Jan 2010 11:38:57 +0100
Message-ID: <4B49AE41.5000206@gmail.com>
References: <20100110103528.GA4769@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:47928 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096Ab0AJKjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 05:39:00 -0500
Received: by fg-out-1718.google.com with SMTP id 19so8509613fgg.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 02:39:00 -0800 (PST)
In-Reply-To: <20100110103528.GA4769@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2010 11:35 AM, Alexey Dobriyan wrote:
>> Stanse found a potential null dereference
> 
> Nobody learns from Coverity, it seems. :^)

If it is known, why the test is still there?

I don't have access to the Coverity results anyway.

> snmp6_unregister_dev() always called with valid idev.

Ok, I'll post a patch to remove the check.

thanks,
-- 
js
