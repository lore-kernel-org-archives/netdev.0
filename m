From: Frans Pop <elendil@planet.nl>
Subject: Re: [Patch] netpoll: warn when there are spaces in parameters
Date: Wed, 17 Mar 2010 11:58:47 +0100
Message-ID: <201003171158.49549.elendil@planet.nl>
References: <20100317101635.5948.23485.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	amwang@redhat.com, davem@davemloft.net
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-To: <20100317101635.5948.23485.sendpatchset@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amerigo Wang wrote:
> +               if (*cur == ' ' || *cur == '\t')
> +                       printk(KERN_INFO "%s: warning: white spaces"
> +                                       "are not allowed.\n", np->name);
> 

The term "white spaces" not correct. Please change the message to
"whitespace is not allowed".

Also, it's normally not necessary to close kernel messages with a period; 
most kernel messages do not have a closing period. Messages are not 
sentences and the periods only help increase the kernel size.

Thanks,
FJP
