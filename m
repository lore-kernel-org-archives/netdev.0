From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Fw: [Kernel-janitors] old ioctl definitions in 2.5
Date: Mon, 15 Sep 2003 15:52:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915155225.3cf90d79.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart_Mon__15_Sep_2003_15:52:25_-0700_097a8d78"
Cc: janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart_Mon__15_Sep_2003_15:52:25_-0700_097a8d78
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


Hi Max,

I think that we need to ask the netdev people about this...

Thanks,
~Randy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Begin forwarded message:

Date: Fri, 12 Sep 2003 13:49:52 +0200
From: maximilian attems <janitor@sternwelten.at>
To: kj <kernel-janitors@osdl.org>
Cc: 
Subject: [Kernel-janitors] old ioctl definitions in 2.5


heyyy :)

include/linux/if_bonding.h contains:
--- snipp
/*
 * We can remove these ioctl definitions in 2.5.  People should use the
 * SIOC*** versions of them instead
*/
#define BOND_ENSLAVE_OLD                (SIOCDEVPRIVATE)
#define BOND_RELEASE_OLD                (SIOCDEVPRIVATE + 1)
#define BOND_SETHWADDR_OLD              (SIOCDEVPRIVATE + 2)
#define BOND_SLAVE_INFO_QUERY_OLD       (SIOCDEVPRIVATE + 11)
#define BOND_INFO_QUERY_OLD             (SIOCDEVPRIVATE + 12)
#define BOND_CHANGE_ACTIVE_OLD          (SIOCDEVPRIVATE + 13)
---
their use is very limited mostly in Documentation/networking/ifenslave.c
and drivers/net/bonding/bond_main.c

do you consider this as a kj case?
shall they be removed?

thx for your ansers!
a++ maks

--Multipart_Mon__15_Sep_2003_15:52:25_-0700_097a8d78
Content-Type: text/plain;
 name="00000000.mimetmp"
Content-Disposition: attachment;
 filename="00000000.mimetmp"
Content-Transfer-Encoding: 7bit

heyyy :)

include/linux/if_bonding.h contains:
--- snipp
/*
 * We can remove these ioctl definitions in 2.5.  People should use the
 * SIOC*** versions of them instead
*/
#define BOND_ENSLAVE_OLD                (SIOCDEVPRIVATE)
#define BOND_RELEASE_OLD                (SIOCDEVPRIVATE + 1)
#define BOND_SETHWADDR_OLD              (SIOCDEVPRIVATE + 2)
#define BOND_SLAVE_INFO_QUERY_OLD       (SIOCDEVPRIVATE + 11)
#define BOND_INFO_QUERY_OLD             (SIOCDEVPRIVATE + 12)
#define BOND_CHANGE_ACTIVE_OLD          (SIOCDEVPRIVATE + 13)
---
their use is very limited mostly in Documentation/networking/ifenslave.c
and drivers/net/bonding/bond_main.c

do you consider this as a kj case?
shall they be removed?

thx for your ansers!
a++ maks






--Multipart_Mon__15_Sep_2003_15:52:25_-0700_097a8d78
Content-Type: application/pgp-signature;
 name="00000001.mimetmp"
Content-Disposition: attachment;
 filename="00000001.mimetmp"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuMC42IChHTlUv
TGludXgpCkNvbW1lbnQ6IEZvciBpbmZvIHNlZSBodHRwOi8vd3d3LmdudXBnLm9yZwoKaUQ4REJR
RS9ZYkxnNi8va1NUTmpvWDBSQW9zNkFKOUIrS2djSjZnU083akVoc3RBd01Kb21HQnFHQUNmYXFs
Ygp2VXhSM2h5RjdKYkpnbDk2bTBtNndSVT0KPXRSUzUKLS0tLS1FTkQgUEdQIFNJR05BVFVSRS0t
LS0tCgo=

--Multipart_Mon__15_Sep_2003_15:52:25_-0700_097a8d78--
