From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Fri, 5 Dec 2003 12:31:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031205123133.3743fe39.davem@redhat.com>
References: <200312021240.PAA01536@yakov.inr.ac.ru>
	<200312051214.48076.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200312051214.48076.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Dec 2003 12:14:47 -0800
Shirley Ma <mashirle@us.ibm.com> wrote:

> I add this because there are some 64-bit counters in the new IPv6 MIBs. 
> This patch has been tested agaist linux-2.6.0-test9, and cleanly applied to 
> linux-2.6.0-test11.

"sizeof(unsigned long)" evaluates to 8 on 64-bit systems,
yet you assume it always evaluated to 4 as on 32-bit systems.

Maybe it would be wiser to explicitly use 'u32' and 'u64' for
the types of the snmp counters?

This has always been a sore area.
