From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 0/2] team: two RCU fixups
Date: Wed, 20 Jun 2012 23:19:36 +0200
Message-ID: <1340227176.4604.1913.camel@edumazet-glaptop>
References: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
	 <20120620.140516.2004640533824596305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48675 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758101Ab2FTVTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 17:19:41 -0400
Received: by bkcji2 with SMTP id ji2so6694032bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 14:19:39 -0700 (PDT)
In-Reply-To: <20120620.140516.2004640533824596305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 14:05 -0700, David Miller wrote:
> From: Jiri Pirko <jpirko@redhat.com>
> Date: Wed, 20 Jun 2012 17:31:59 +0200
> 
> > Jiri Pirko (2):
> >   team: use rcu_access_pointer to access RCU pointer by writer
> >   team: use RCU_INIT_POINTER for NULL assignment of RCU pointer
> 
> Applied, but this makes your subsequent patch not apply.

I reviewed them and spotted problems, and you applied them...

Then Jiri sent an update.
