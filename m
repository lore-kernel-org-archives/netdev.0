From: Tomas Agartz <tlund@nxs.se>
Subject: Re: unmanaged L2TPv3 ethernet pseudowire Cisco <=> Linux
Date: Wed, 27 Mar 2013 21:08:14 +0100 (CET)
Message-ID: <Pine.LNX.4.61.1303272104470.20041@envy.nxs.se>
References: <Pine.LNX.4.61.1303241153000.20041@envy.nxs.se>
 <CAEwTi7Rbo3dBqhyDJXYvrkMWfrX9xwUr5VovFoW7BfPAZp4XFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from envy.nxs.se ([212.247.200.182]:38181 "EHLO envy.nxs.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365Ab3C0UIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 16:08:17 -0400
In-Reply-To: <CAEwTi7Rbo3dBqhyDJXYvrkMWfrX9xwUr5VovFoW7BfPAZp4XFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Mar 2013, James Chapman wrote:

> The issue is that Linux and Cisco use a different default for the 
> L2SpecificSublayer header setting and neither implementation provides a 
> config option to change its setting. :-( The Linux default is to use the 
> Default L2SpecificSublayer as defined in the RFC. Unfortunately the 
> Cisco default is to use no L2SpecificSublayer.
>
> The kernel already has an API to allow the L2SpecificSublayer setting to 
> be configured. The missing piece is an iproute2 l2tp config option to 
> configure it. I'll work on an iproute2 patch now to allow this setting 
> to be configured.

I patched my iproute2 with your patch and now my tunnel is working. Thank 
you! :)

> For unmanaged tunnels, these parameters must be manually configured 
> consistently at each side. Both Cisco and Linux default to use no 
> cookies and both already have config parameters to set cookie 
> parameters, if needed. However, for L2SpecificSublayer this isn't the 
> case. We need to add a config option on the Linux side to force the same 
> setting as Cisco is using.

Does the API in the kernel allow you to set the cookie? In that 
case it seems like a good idea to add that to iproute2 as well?

//tlund
