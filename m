From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2] vxlan: correctly validate VXLAN ID against
 VXLAN_N_VID
Date: Thu, 23 Feb 2017 17:26:16 +0100
Message-ID: <20170223172616.50111b3a@griffin>
References: <4650647d72b8f219cb725b40de9b4627f3306919.1487866739.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751110AbdBWQfO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 11:35:14 -0500
In-Reply-To: <4650647d72b8f219cb725b40de9b4627f3306919.1487866739.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Feb 2017 17:19:41 +0100, Matthias Schiffer wrote:
> The incorrect check caused an off-by-one error: the maximum VID 0xffffff
> was unusable.
> 
> Fixes: d342894c5d2f ("vxlan: virtual extensible lan")
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
> ---
> v2: check against VXLAN_N_VID instead of changing operator

Acked-by: Jiri Benc <jbenc@redhat.com>

Thanks!

 Jiri
