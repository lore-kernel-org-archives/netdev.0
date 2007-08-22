From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] improved xfrm_audit_log() patch
Date: Wed, 22 Aug 2007 12:51:57 -0700 (PDT)
Message-ID: <20070822.125157.43008100.davem@davemloft.net>
References: <200708151616.l7FGGTk9001632@faith.austin.ibm.com>
	<20070821.002405.88473654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: latten@austin.ibm.com
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20070821.002405.88473654.davem@davemloft.net>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 21 Aug 2007 00:24:05 -0700 (PDT)

> Looks good, applied to net-2.6.24, thanks Joy.

Something is still buggered up in this patch, you can't add this local
"audit_info" variable unconditionally to these functions, and
alternatively you also can't add a bunch of ifdefs to xfrm_user.c to
cover it up either.

  CC [M]  net/xfrm/xfrm_user.o
net/xfrm/xfrm_user.c: In function $,1rx(Bxfrm_add_sa$,1ry(B:
net/xfrm/xfrm_user.c:450: warning: unused variable $,1rx(Baudit_info$,1ry(B
net/xfrm/xfrm_user.c: In function $,1rx(Bxfrm_del_sa$,1ry(B:
net/xfrm/xfrm_user.c:525: warning: unused variable $,1rx(Baudit_info$,1ry(B
net/xfrm/xfrm_user.c: In function $,1rx(Bxfrm_add_policy$,1ry(B:
net/xfrm/xfrm_user.c:1140: warning: unused variable $,1rx(Baudit_info$,1ry(B
net/xfrm/xfrm_user.c: In function $,1rx(Bxfrm_get_policy$,1ry(B:
net/xfrm/xfrm_user.c:1404: warning: unused variable $,1rx(Baudit_info$,1ry(B
net/xfrm/xfrm_user.c: In function $,1rx(Bxfrm_add_pol_expire$,1ry(B:
net/xfrm/xfrm_user.c:1651: warning: unused variable $,1rx(Baudit_info$,1ry(B
net/xfrm/xfrm_user.c: In function $,1rx(Bxfrm_add_sa_expire$,1ry(B:
net/xfrm/xfrm_user.c:1688: warning: unused variable $,1rx(Baudit_info$,1ry(B

So I'm going to revert for now.  Let me know when you have
a fixed version of the patch.

Thanks.
