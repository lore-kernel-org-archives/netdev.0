From: Rakib Mullick <rakib.mullick@gmail.com>
Subject: Re: [PATCH -mm] connector: Passing required parameter for function
	cn_add_callback.
Date: Tue, 13 Oct 2009 11:27:49 +0600
Message-ID: <b9df5fa10910122227r710d6782m89fc9ec4273487b8@mail.gmail.com>
References: <b9df5fa10910111944s274207aica39c0e646c10f7a@mail.gmail.com>
	 <20091011.223502.77690228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, zbr@ioremap.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757367AbZJMF21@vger.kernel.org>
In-Reply-To: <20091011.223502.77690228.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/09, David Miller <davem@davemloft.net> wrote:
> From: Rakib Mullick <rakib.mullick@gmail.com>
>  Date: Mon, 12 Oct 2009 08:44:33 +0600
>
>
>  >   */
>  > -static void cn_proc_mcast_ctl(struct cn_msg *msg)
>  > +static void cn_proc_mcast_ctl(struct cn_msg *msg, struct
>  > netlink_skb_parms *nsp)
>
>
> Your patches are unusable because your email client corrupts the
>  patch, here you can see it is splitting up long lines.
>
>  Please fix this up and resubmit.
Oops..... sorry for that. This is the second time I'm facing this
problem. I'll try to fix it.
I'm resubmitting the patch. Here I've recreate the patch to split the
line into two.
And it just reaches its 80 line mark. Hopefully it will be okay.

Thanks,

----
Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>

--- linus/drivers/connector/cn_proc.c	2009-10-09 17:38:22.000000000 +0600
+++ rakib/drivers/connector/cn_proc.c	2009-10-13 12:29:37.000000000 +0600
@@ -225,9 +225,11 @@ static void cn_proc_ack(int err, int rcv

 /**
  * cn_proc_mcast_ctl
- * @data: message sent from userspace via the connector
+ * @msg: message sent from userspace via the connector
+ * @nsp: remains unused but we need it to keep it
  */
-static void cn_proc_mcast_ctl(struct cn_msg *msg)
+static void cn_proc_mcast_ctl(struct cn_msg *msg,
+				struct netlink_skb_parms *nsp)
 {
 	enum proc_cn_mcast_op *mc_op = NULL;
 	int err = 0;
