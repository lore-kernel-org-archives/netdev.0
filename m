From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] pasemi_mac: mac_to_intf() error not noticed
Date: Thu, 23 Apr 2009 14:54:03 -0500
Message-ID: <20090423195403.GA4785@lixom.net>
References: <49F0A8E9.2010702@gmail.com> <20090423175648.GA4406@lixom.net> <49F0B920.1050704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:52047 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbZDWTwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 15:52:36 -0400
Content-Disposition: inline
In-Reply-To: <49F0B920.1050704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 08:53:20PM +0200, Roel Kluin wrote:
> Olof Johansson wrote:
> > On Thu, Apr 23, 2009 at 07:44:09PM +0200, Roel Kluin wrote:
> > This can in practice never happen which is likely why it went
> > unnoticed.
> 
> > define a new variable with an appropriate name, please.
> 
> Ok, how's this?

Good, but you might have to repost without the email trail above the
patch description. Normally putting it under the signed-off-by line
with three dashes between will make sure it doesn't get picked up by
the git tools.


Anyway, that's all up to Dave, if you end up reposting feel free to add:

> --------------------------->8-------------8<------------------------------
> mac_to_intf() can return -1 when no device or function is found, but when
> mac->dma_if is unsigned. The error wasn't noticed.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Acked-by: Olof Johansson <olof@lixom.net>

