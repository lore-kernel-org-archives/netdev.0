From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 10:02:21 +0200
Message-ID: <20151016100221.6fd5034f@griffin>
References: <cover.1444926905.git.jbenc@redhat.com>
	<20151015.235007.973370825335101214.davem@davemloft.net>
	<20151016093945.54a6a7aa@griffin>
	<20151016.010644.2090038835491896678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbbJPICZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 04:02:25 -0400
In-Reply-To: <20151016.010644.2090038835491896678.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Oct 2015 01:06:44 -0700 (PDT), David Miller wrote:
> No, it's definitely not OK, because lwtunnel support exists in
> Linus's tree.
> 
> And tools should be able to work on all kernels where lwtunnel support
> is available.

You can consider the lwtunnels feature as not finished in the current
Linus's tree. It works, it won't change (thus anything using it in its
current form will continue to work in all the future kernels), but
mainstream tools won't make use of it until a kernel version later
which will get some additional support.

I don't think it's much of a problem and I don't think it is the first
time this would happen.

I'm afraid I don't have any solution that could do better.

 Jiri

-- 
Jiri Benc
