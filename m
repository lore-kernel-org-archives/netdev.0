From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: [margitsw@t-online.de: Re: [PATCH 6/17 linux-2.6.7-rc2] prism54: Kernel compatibility (resend)]
Date: Fri, 11 Jun 2004 02:43:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040611064309.GH24773@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----- Forwarded message from Margit Schubert-While <margitsw@t-online.de> -----

To: Jeff Garzik <jgarzik@pobox.com>
From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [PATCH 6/17 linux-2.6.7-rc2] prism54: Kernel compatibility
  (resend)
Cc: mcgrof@ruslug.rutgers.edu
X-Seen: false
X-ID: S8bLN4ZZQeIA8qC+ZpICD6L0IGei0K+D9QQxKNHm+ij+0kUy-mO-85

Hi Jeff,
At 20:04 10.06.2004 -0400, you wrote:
>I believe I misread patch #6 before, it seems fine.
>
>Applied patches 6 through 17.

OK. Super. Thanks.

Quick question - I have the next set of patches ready.
These are not obtrusive -
 function definition cleanup (extraneous inlines, missing static)
 wmb() -> smp_wmb()
 dev_kfree_skb(_irq) -> dev_kfree_skb_any
They depend on the previous patches 1 - 17.
Should I wait until patches 1- 17 appear in kernel BK or can I
start to send now ?

Just for info - re. the question of ->
#define init_wds 0
 versus
static const int init_wds = 0;

I did some tests and it appears that gcc's < 3.3.3 don't
optimize out the static const correctly. gcc 3.3.3 produces
exactly the same code for both definitions. (ie. it optimizes
it completely out)
(Tested gcc versions 2.95, 3.2.1, 3.3.1, 3.3.3)
Anyway, in the last patches, I left it as was ie. static const.

Thanks again.

Cheers

Margit


----- End forwarded message -----

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
