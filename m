From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 15 Jan 2004 00:57:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115005729.381c9ee0.davem@redhat.com>
References: <200312021240.PAA01536@yakov.inr.ac.ru>
	<200312051214.48076.mashirle@us.ibm.com>
	<20031205123133.3743fe39.davem@redhat.com>
	<200401141450.43806.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200401141450.43806.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004 14:52:51 -0800
Shirley Ma <mashirle@us.ibm.com> wrote:

> > "sizeof(unsigned long)" evaluates to 8 on 64-bit systems,
> > yet you assume it always evaluated to 4 as on 32-bit systems.
> >
> > Maybe it would be wiser to explicitly use 'u32' and 'u64' for
> > the types of the snmp counters?
> >
> > This has always been a sore area.
> 
> This is the new patch against 2.6.1 kernel.

I am personally fine with this patch, but I do believe some folks might find
it controversial (for whatever reason) to move all of these stats over to 64-bits.

So I'm going to let this sit for another day or two so people can voice any
objections they may have.
