From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: want to randomly drop packets based on percent
Date: Mon, 17 Apr 2006 09:19:15 -0700
Message-ID: <20060417091915.67e28361@localhost.localdomain>
References: <444345F9.4090100@cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23745 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751035AbWDQQTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 12:19:21 -0400
To: George Nychis <gnychis@cmu.edu>
In-Reply-To: <444345F9.4090100@cmu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Apr 2006 03:38:33 -0400
George Nychis <gnychis@cmu.edu> wrote:

> Hey,
> 
> I'm using the 2.4.32 kernel with madwifi and iproute2 version 
> 2-2.6.16-060323.tar.gz
> 
> I wanted to insert artificial packet loss based on a percent so i found:
> network emulab qdisc could do it, so i compiled support into the kernel 
> and tried:
> tc qdisc change dev eth0 root netem loss .1%

Most likely, you the version of the kernel you are running was not
configured with netem enabled.
