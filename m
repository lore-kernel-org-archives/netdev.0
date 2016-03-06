From: f6bvp <f6bvp@free.fr>
Subject: Re: [Patch] rose_route_frame() NULL pointer dereference kernel panic
Date: Sun, 6 Mar 2016 11:58:35 +0100
Message-ID: <56DC0D5B.1040408@free.fr>
References: <56D5FD7A.5080104@free.fr>
 <20160303.170253.1102862150292919836.davem@davemloft.net>
 <56DAFC1A.5000408@free.fr>
 <20160305.112226.2192524821017178121.davem@davemloft.net>
 <56DB1814.2050902@free.fr>
 <20160305195715.GA16052@electric-eye.fr.zoreil.com>
 <56DC0B8A.5030708@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ralf@linux-mips.org, "Eric W. Biederman\"" <ebiederm@xmission.com>,
	linux-hams@vger.kernel.org, Bernard Pidoux <bernard.pidoux@free.fr>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <56DC0B8A.5030708@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ran=C3=A7ois,

Thank you for providing information about rose_rebuild_header history.
I was not able to find Jonathan Naylor G4KLX email.
However as rose_xmit() has been recently changed by Eric Biederman, he
may have more precise information about rose_route_frame()
NULL argument.
Meanwhile, I browsed into rose_route.c release 001 you referenced and f=
ound
an interesting comment before rose_route_frame() :
+/*
+ * Route a frame to an appropriate AX.25 connection. A NULL ax25_cb
+ * indicates an internally generated frame.
+ */
+int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)

Now, I hope that ROSE guru will explain us what means an "internally
generated frame" and if, by chance, it means that it is not to be sent
via a net device, but rather to be used locally ?

Bernard

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
