From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next 3/7] inetpeer: use generic union inet_addr
Date: Mon, 22 Jul 2013 19:26:11 -0700
Message-ID: <1374546371.4990.113.camel@edumazet-glaptop>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374476713-8838-4-git-send-email-amwang@redhat.com>
	 <1374506315.4990.14.camel@edumazet-glaptop> <1374545131.24933.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:58692 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab3GWC0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 22:26:14 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so9029036obc.31
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 19:26:13 -0700 (PDT)
In-Reply-To: <1374545131.24933.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 10:05 +0800, Cong Wang wrote:
> On Mon, 2013-07-22 at 08:18 -0700, Eric Dumazet wrote:
> > On Mon, 2013-07-22 at 15:05 +0800, Cong Wang wrote:
> > > From: Cong Wang <amwang@redhat.com>
> > > 
> > > struct inetpeer_addr is pretty similar to generic union inet_addr,
> > > therefore can be safely converted to it.
> > 
> > Its 'safe' but adds 50% increase for struct tcp_metrics_block
> > 
> > I fail to see this mentioned in the changelog.
> 
> I asked you in RFC, but you don't give me any response, this is the
> reason. :)
> 

I mentioned an increase in size of the structures, you replied :
"rearrange the fields of struct inet_peer in case of cacheline miss?"
which was a complete different matter, I had other more urgent work I
guess.

> > I guess its no big deal, but why do you think this code used hand coded
> > functions instead of generic ?
> > 
> > 
> > 
> 
> I don't understand what you are asking here, seems totally unrelated
> with the point you raised above, therefore I am completely confused...

You are sending a patch with possible performance impact, and you only
says "its safe", without any real study. It might have an impact, who
knows.

I said "its no big deal", so consider this as an informative message.
