From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Thu, 09 Dec 2010 07:46:41 -0500
Message-ID: <1291898801.2965.6.camel@Dan>
References: <1291863926.2965.1.camel@Dan>
	 <1291865039.2795.46.camel@edumazet-laptop>  <1291895472.2965.4.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291895472.2965.4.camel@Dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > So caller can not block BH ?
> > 
> > This seems wrong to me, please consider :
> > 
> > normal process context :
> > 
> > spin_lock_bh() ...
> > 
> > for (...)  
> > 	{xxx}printf( ...   "%pK"   ...)
> > 
> > spin_unlock_bh();
> > 
> 
> I will think about this and address it.

Would you be happier if I omitted the in_interrupt() check entirely?

-Dan
