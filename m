From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: add option to build m_xt as a tc module.
Date: Mon, 12 Apr 2010 08:33:17 -0700
Message-ID: <20100412083317.0d9e9f3f@nehalam>
References: <20100412115538.GA28338@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53673 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175Ab0DLQ1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 12:27:32 -0400
In-Reply-To: <20100412115538.GA28338@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Apr 2010 13:55:38 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> Add TC_CONFIG_XT_MODULE option that can be added
> either to Config (after ./configure) or as an argument to "make".

I like the idea and will incorporate it, but do not like having more
build options. Adding more configuration options like this is just
lazy design "we can't figure this out, let's make the user do it".

So put the patch in but there it will always be true.
