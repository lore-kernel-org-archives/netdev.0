From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: 16 Sep 2003 11:18:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063703910.5948.85.camel@henrik.marasystems.com>
References: <200309022116.41697.bdschuym@pandora.be>
	 <200309132159.37834.bdschuym@pandora.be>
	 <20030915155903.12a3f95d.davem@redhat.com>
	 <200309160805.08171.bdschuym@pandora.be>
	 <20030915230259.79f5a545.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bart De Schuymer <bdschuym@pandora.be>, laforge@netfilter.org,
   acme@conectiva.com.br, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030915230259.79f5a545.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

tis 2003-09-16 klockan 08.02 skrev David S. Miller:

> Also, another solution could be to store the object inside the kernel
> using a different structure, one where you can guarentee the alignment
> of these things properly.

unfortunately iptables does not allow such differences between userspace
and kernel representation..

-- 
Henrik Nordstrom <hno@marasystems.com>
MARA Systems AB
