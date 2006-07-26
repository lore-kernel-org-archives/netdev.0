From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] kevent: core files.
Date: Wed, 26 Jul 2006 14:37:01 +0400
Message-ID: <20060726103701.GA10459@2ka.mipt.ru>
References: <11539054941027@2ka.mipt.ru> <11539054952689@2ka.mipt.ru> <20060726033105.7cd173b8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	drepper@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:24459 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932236AbWGZKh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 06:37:26 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060726033105.7cd173b8.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 03:31:05AM -0700, Andrew Morton (akpm@osdl.org) wrote:
> Please indent the body of the switch one tabstop to the left.
..
> If the user passes this an fd which was obtained via means other than
> kevent_ctl_init(), the kernel will explode.  Do
> 
> 	if (file->f_fop != &kevent_user_fops)
> 		return -EINVAL;

Thanks, I will implement both.

-- 
	Evgeniy Polyakov
