From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 13:17:31 +0000
Message-ID: <20090226131731.GA6294@ff.dom.local>
References: <D2EC00C0-1CEE-4A88-B0D8-B60B59EEBA3D@sevsky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denis Romanenko <ash@sevsky.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:64761 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756351AbZBZNRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 08:17:39 -0500
Received: by fxm24 with SMTP id 24so506563fxm.37
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 05:17:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <D2EC00C0-1CEE-4A88-B0D8-B60B59EEBA3D@sevsky.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-02-2009 13:51, Denis Romanenko wrote:
>> On Thu, Feb 26, 2009 at 12:00:52PM +0000, Jarek Poplawski wrote:
>>> On 26-02-2009 12:24, Denis Romanenko wrote:
>>> ...
>>>> hmm - for stabibility can i disable netconsole ? Or this bug is not
>>>> give my resutlts (reboot of router after 1-2 weeks of work )?
>> Hmm... To make sure: you have these reboots without netconsole, right?
>>
> 
> on old kernels - (without patch #4 from you) (2.6.27.3-2.6.27.7) - its  
> rebooted without netconsole

OK, there was this hrtimers vs. htb lockup bug.

> Now netconsole enabled and loaded by default

So try to check without netconcole too.

Jarek P.

PS: and try to Cc me sometimes, btw...
