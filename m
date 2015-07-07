From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH iproute2] include: add copy of tipc.h
Date: Tue, 7 Jul 2015 08:43:32 +0200
Message-ID: <20150707064332.GA8224@unicorn.suse.cz>
References: <20150629085315.B6DECA0BA1@unicorn.suse.cz>
 <20150706144649.5484bce6@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34901 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164AbbGGGne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2015 02:43:34 -0400
Content-Disposition: inline
In-Reply-To: <20150706144649.5484bce6@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2015 at 02:46:49PM -0700, Stephen Hemminger wrote:
> On Mon, 29 Jun 2015 10:53:15 +0200 (CEST)
> Michal Kubecek <mkubecek@suse.cz> wrote:
> 
> > Copy of kernel include/uapi/linux/tipc.h is needed to build on systems
> > with pre-3.16 kernel headers.
> > 
> > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> 
> Ok, I applied (and fixed) this.
> The headers you want are not directly from include/uapi/linux, instead
> you need to run:
>  $ make install_headers
> 
> Then copy the result out of usr/include/linux/ when getting a santized
> header.

Thank you for the explanation. I was looking for some script automating
the header sanitization but I didn't realize I should have looked into
kernel git, not iproute2. I'll remember for the future.

                                                         Michal Kubecek
