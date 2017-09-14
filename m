From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2] vxlan: only reduce known arp broadcast request to
 support virtual IP
Date: Thu, 14 Sep 2017 18:14:03 +0200
Message-ID: <20170914181403.5cd14593@griffin>
References: <20170914151440.GA30675@samsung>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Chen Haiquan <oc@yunify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57834 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751545AbdINQOG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 12:14:06 -0400
In-Reply-To: <20170914151440.GA30675@samsung>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Sep 2017 23:14:40 +0800, Chen Haiquan wrote:
> +static bool arp_reduce_ignore_unknown_ip;
> +module_param(arp_reduce_ignore_unknown_ip, bool, 0644);
> +MODULE_PARM_DESC(arp_reduce_ignore_unknown_ip,
> +		 "Only reduce known arp broaddcast request to support virtual IP");

Oh, no. This is not the way. It needs to be a runtime configuration
option (a netlink attribute). Generally, every time you find yourself
adding a module parameter, you're doing something wrong.

Also, net-next is currently closed. You should not submit new features
during this period, it's bugfixes only now.
http://vger.kernel.org/~davem/net-next.html

 Jiri
