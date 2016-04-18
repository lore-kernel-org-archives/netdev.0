From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: switchdev fib offload issues
Date: Mon, 18 Apr 2016 11:11:26 -0600
Message-ID: <5715153E.6060005@cumulusnetworks.com>
References: <20160418154757.GA2059@nanopsycho.amit.cz>
 <AM4PR0501MB19409325D618C1C2E9519E9FDB6B0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ilan Tayari <ilant@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36169 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcDRRL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 13:11:29 -0400
Received: by mail-io0-f177.google.com with SMTP id u185so201116679iod.3
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 10:11:28 -0700 (PDT)
In-Reply-To: <AM4PR0501MB19409325D618C1C2E9519E9FDB6B0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/16 10:38 AM, Ilan Tayari wrote:
> Hi Jiri,
>
>> Thoughts?
>
> One general thought comes to mind, regardless of your proposed solutions:
>
> You'll need to take care to propagate the error properly in case of routes created by the kernel, such as local routes.
> Local routes are created when an IP address is added to an interface, so in such a case would the whole add-ip-address operation be rolled back cleanly?

local routes are added on an 'admin up' too which is completely 
disconnected from adding the address to the interface.
