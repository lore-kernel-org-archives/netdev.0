From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Fri, 10 Dec 2010 08:18:46 -0800
Message-ID: <20101210081846.58b67f09@nehalam>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45250 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755973Ab0LJQSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 11:18:48 -0500
In-Reply-To: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Dec 2010 16:58:12 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> Allow the users to specify a wildcard when selecting a device:
> 
> $ ip set link dev dummy* up
> 
> We do this by expanding the original command line in multiple lines
> which we then feed via a pipe to a forked ip processed run in batch
> mode.
> 


Seems like feature creep. Can't you do this with bash completion
script instead.
