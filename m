From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Tue, 15 Aug 2006 04:36:14 +0400
Message-ID: <20060815003614.GA8677@ms2.inr.ac.ru>
References: <20060814213718.580598840@postel.suug.ch> <20060814214341.834971519@postel.suug.ch> <1155598991.6946.42.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:12426 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932760AbWHOAgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 20:36:47 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155598991.6946.42.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Some of these removals of current->pid will affect users such as quagga,
> zebra, vrrpd etc.

If they survived cleanup in IPv4, they definitely will not feel cleanup
in IPv6.

Thomas does great work, Jamal, do not worry. :-)


> IMO, I believe there is a strong case that can be made for events that
> were caused by non-netlink users such as ioctls that could at least be
> multicast with current->pid.

Highly not desired.


> It would also be acceptable if the quagga etc folks could meet their
> goals some other way.

To all that I remember, that past discussion essentially closed the question.

Alexey
