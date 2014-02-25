From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC v4 0/12] vti4: prepare namespace and interfamily
 support.
Date: Tue, 25 Feb 2014 08:42:06 +0100
Message-ID: <20140225074206.GJ32371@secunet.com>
References: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53347 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbaBYHmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 02:42:10 -0500
Content-Disposition: inline
In-Reply-To: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 09:30:08AM +0100, Steffen Klassert wrote:
> I decided to do a RFC v4 patchset because there accumulated enough
> fixes during some 'real life' tests. The changelog is below.
> 
> This patchset prepares vti4 for proper namespace and interfamily support.
> 

This is now applied to ipsec-next. Only change is a build fix for
an odd configuration where CONFIG_XFRM is set but CONFIG_INET
is not set.

The ipv6 side is comming as soon as the ipsec-next tree gets
merged into net-next for the next time.
