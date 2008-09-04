From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/37] netns ct: add netns boilerplate
Date: Thu, 04 Sep 2008 18:15:28 +0200
Message-ID: <48C009A0.4050202@trash.net>
References: <20080821215850.GF31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080821215850.GF31136@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adobriyan@gmail.com wrote:
> One comment: #ifdefs around #include is necessary to overcome amazing compile
> breakages in NOTRACK-in-netns patch (see below).

I guess thats because of the net/netfilter/nf_conntrack.h inclusion.
We should fix that, its spreading to too many places.

Anyways, applied.
