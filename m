From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH - RFC] [1/2] 2.6 must-fix list - kernel error reporting
Date: Thu, 10 Jul 2003 14:42:44 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307101419080.15602-100000@excalibur.intercode.com.au>
References: <3F0AFFE6.E85FF283@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
   Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
   Randy Dunlap <rddunlap@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jim Keniston <jkenisto@us.ibm.com>
In-Reply-To: <3F0AFFE6.E85FF283@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Jul 2003, Jim Keniston wrote:

+       kerror_nl = netlink_kernel_create(NETLINK_KERROR, kerror_netlink_rcv);
+       if (kerror_nl == NULL)
+               panic("kerror_init: cannot initialize kerror_nl\n");

You can simply use NULL instead of passing the dummy kerror_netlink_rcv
function.

+struct kern_log_entry {
+       __u16   log_kmagic;     /* always LOGREC_KMAGIC */
+       __u16   log_kversion;   /* which version of this struct? */
+       char    log_facility[FACILITY_MAXLEN];  /* e.g., driver name */

These fields should generally be specified in ascending order to help with 
alignment.

It may also be worth looking at how the ULOG code batches messages to 
improve peformance.




- James
-- 
James Morris
<jmorris@intercode.com.au>
