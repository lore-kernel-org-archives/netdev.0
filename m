From: "David S. Miller" <davem@davemloft.net>
Subject: [KJ] Re: [PATCH] Deinitialise static variables in net/core/pktgen.c
Date: Thu, 22 Dec 2005 12:52:32 -0800 (PST)
Message-ID: <20051222.125232.110191612.davem@davemloft.net>
References: <17299.192.96.150.57.1135065563.squirrel@mail.interexcel.co.za>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============75211402668471772=="
Cc: netdev@vger.kernel.org, lkml@vger.kernel.org,
   kernel-janitors@lists.osdl.org
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: jaco@kroon.co.za
In-Reply-To: <17299.192.96.150.57.1135065563.squirrel@mail.interexcel.co.za>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============75211402668471772==
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

From: "Jaco Kroon" <jaco@kroon.co.za>
Date: Tue, 20 Dec 2005 09:59:23 +0200 (SAST)

> static variables should not be explicitly initialised to 0.  This causes
> them to be placed in .data instead of .bss.  This patch de-initialises 3
> static variables in net/core/pktgen.c.
> 
> There are approximately 800 more such variables in the source tree
> (2.6.15rc5).  If there is more interrest I'd be willing to track down the
> rest of these as well and de-initialise them as well.

Applied, _but_:

1) Please provide a "Signed-off-by: " line next time.
2) Please send the patches in such a way that your email
   client doesn't corrupt that patch, there were newlines
   added etc.

Thanks.

--===============75211402668471772==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============75211402668471772==--
