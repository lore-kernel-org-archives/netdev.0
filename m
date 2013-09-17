From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net loopback: Set loopback_dev to NULL when
 freed
Date: Mon, 16 Sep 2013 18:41:42 -0700
Message-ID: <1379382102.4751.2.camel@edumazet-glaptop>
References: <CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	 <87k3iggw8m.fsf_-_@xmission.com> <1379379051.4751.0.camel@edumazet-glaptop>
	 <20130916.213435.1508866100258405440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org, fruggeri@aristanetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61279 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722Ab3IQBlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:41:44 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so4828684pdj.7
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 18:41:43 -0700 (PDT)
In-Reply-To: <20130916.213435.1508866100258405440.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-16 at 21:34 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 16 Sep 2013 17:50:51 -0700
> 
> > On Mon, 2013-09-16 at 16:52 -0700, Eric W. Biederman wrote:
> >> It has recently turned up that we have a number of long standing bugs
> >> in the network stack cleanup code with use of the loopback device
> >> after it has been freed that have not turned up because in most cases
> >> the storage allocated to the loopback device is not reused, when those
> >> accesses happen.
> >> 
> >> Set looback_dev to NULL to trigger oopses instead of silent data corrupt
> >> when we hit this class of bug.
> >> 
> >> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> >> ---
> > 
> > Acked-by: Eric Dumazet <edumazet@google.com>
> 
> I'd like to apply this to 'net', any objections?

No objections from me.
