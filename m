From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 2/2] netpoll: use the net namespace of current
 process instead of init_net
Date: Sat, 26 Jan 2013 18:00:32 +0800
Message-ID: <1359194432.2654.1.camel@cr0>
References: <1358931731-17438-1-git-send-email-amwang@redhat.com>
	 <1358931731-17438-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117Ab3AZKAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jan 2013 05:00:45 -0500
In-Reply-To: <1358931731-17438-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 17:02 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> This will allow us to setup netconsole in a different namespace
> rather than where init_net is.
> 

Hmm, I missed to put the netns in netpoll_cleanup()...

Will send v2.
