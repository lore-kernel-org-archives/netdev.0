From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Fri, 5 Dec 2003 13:55:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF90F24EBE.441563EE-ON87256DF3.00782111@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Thanks, Dave. When I created the patch, I was concern about this.
I will change the MIBs counters to 'u32' or 'u64'.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



"David S. Miller" <davem@redhat.com> on 12/05/2003 12:31:33 PM

To:    mashirle@us.ltcfwd.linux.ibm.com
cc:    kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Shirley
       Ma/Beaverton/IBM@IBMUS
Subject:    Re: [PATCH]snmp6 64-bit counter support in proc.c


On Fri, 5 Dec 2003 12:14:47 -0800
Shirley Ma <mashirle@us.ibm.com> wrote:

> I add this because there are some 64-bit counters in the new IPv6 MIBs.
> This patch has been tested agaist linux-2.6.0-test9, and cleanly applied
to
> linux-2.6.0-test11.

"sizeof(unsigned long)" evaluates to 8 on 64-bit systems,
yet you assume it always evaluated to 4 as on 32-bit systems.

Maybe it would be wiser to explicitly use 'u32' and 'u64' for
the types of the snmp counters?

This has always been a sore area.
