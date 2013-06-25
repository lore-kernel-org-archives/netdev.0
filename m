From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: freeze with interface rename & SIOCGIFNAME
Date: Tue, 25 Jun 2013 10:05:33 -0700
Message-ID: <1372179933.3301.106.camel@edumazet-glaptop>
References: <51C9BB9C.4050405@freebox.fr>
	 <1372176951.3301.103.camel@edumazet-glaptop> <51C9C4FF.1020706@freebox.fr>
	 <1372179447.3301.105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:65476 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab3FYRF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 13:05:26 -0400
Received: by mail-ee0-f51.google.com with SMTP id e52so6959663eek.10
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 10:05:24 -0700 (PDT)
In-Reply-To: <1372179447.3301.105.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 09:57 -0700, Eric Dumazet wrote:

> I am not sure it's needed, because the writer holds a spinlock and is
> not allowed to sleep or being preempted.
> 
> If it's needed, there is a bug somewhere else...

Oh well, its a write_seqcount, so no spinlock...
