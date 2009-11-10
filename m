From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] support static-only systems
Date: Tue, 10 Nov 2009 10:45:51 -0800
Message-ID: <20091110104551.1aff249d@nehalam>
References: <1257505762-13819-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53778 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693AbZKJSqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:46:17 -0500
In-Reply-To: <1257505762-13819-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  6 Nov 2009 06:09:22 -0500
Mike Frysinger <vapier@gentoo.org> wrote:

> The iptables code supports a "no shared libs" mode where it can be used
> without requiring dlfcn related functionality.  This adds similar support
> to iproute2 so that it can easily be used on systems like nommu Linux (but
> obviously with a few limitations -- no dynamic plugins).
> 
> Rather than modify every location that uses dlfcn.h, I hooked the dlfcn.h
> header with stub functions when shared library support is disabled.  Then
> symbol lookup is done via a local static lookup table (which is generated
> automatically at build time) so that internal symbols can be found.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---

Both applied thanks.


-- 
