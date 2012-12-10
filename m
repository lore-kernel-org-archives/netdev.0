From: Sri Ram Vemulpali <sri.ram.gmu06@gmail.com>
Subject: netfilter question
Date: Mon, 10 Dec 2012 15:12:38 -0500
Message-ID: <CALyraeOdiCD+cbQZoyRZYPmzC3Kzivk8daK=PYT8uT9HwFpacQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-netdev <netdev@vger.kernel.org>,
	linux-kernel-mail <linux-kernel@vger.kernel.org>,
	linux-newbie@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guys,

I am writing a netfilter hooks module for applying kernel rules on
incoming packets. I am implementing hook at NF_IP_PRE_ROUTING.

>From my understanding, after sk_buff passing NF_IP_PRE_ROUTING hook
enters into ip_forward (routing) path, which will determine whether
packet is for local host, if not for local host, then routes to
destination host based on IP header destination info through local
host interface.

My question is, if I modify sk_buff packet ip header info at
NF_IP_PRE_ROUTING hook, with values of external host ip (destination
host), therefore I think this packet will be routed to destination
host from right source interface. Instead passing it to local host.

Please correct my assumption. Or is anything more I should be doing.
Because I am building a system to route the packets applying kernel
rules.

thanks in advance.

-- 
Regards,
Sri.
