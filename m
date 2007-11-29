From: =?us-ascii?Q?=3D=3Futf-8=3Fq=3FFerenc=5FW=3DC3=3DA1gner=3F=3D?=
	<wferi@niif.hu>
Subject: [PATCH 4/3] net/bonding: Adhere to coding style: break line after the if condition
Date: Thu, 29 Nov 2007 01:16:51 +0100
Message-ID: <87wss1c3d8.fsf_-_@szonett.ki.iif.hu>
References: <871wabkxcd.fsf@szonett.ki.iif.hu>
	<20071127194929.757e4ebe.randy.dunlap@oracle.com>
	<87bq9ekb8m.fsf@szonett.ki.iif.hu> <474D8B83.9050609@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, wferi@niif.hu
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762116AbXK2ARR@vger.kernel.org>
In-Reply-To: <474D8B83.9050609@oracle.com> (Randy Dunlap's message of "Wed, 28
	Nov 2007 07:38:43 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ferenc W=C3=A1gner <wferi@niif.hu>
---
Randy Dunlap <randy.dunlap@oracle.com> writes:

> Wagner Ferenc wrote:
>> Randy Dunlap <randy.dunlap@oracle.com> writes:
>>
>>> Patches 1 & 3 use
>>>
>>> 	if (res) statement;
>>>
>>> but the preferred form is
>>>
>>> 	if (res)
>>> 		statement;
>>>
>>> Even if this style was already used in the source file, it should
>>> be cleaned up.
>>
>> No principal problem.  So that I learn something useful: how should =
I
>> go about this?  I created the patches with git-format-patch, and the=
y
>> depend on each other, so I'd rather not git-reset, if possible...
>>
>> Can I just create a follow-up patch which fixes this stylistic issue=
?
>
> That's OK with me.  I can't say how it might be done with git.

 drivers/net/bonding/bond_sysfs.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index 5c31f5c..9de2c52 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -91,7 +91,8 @@ static ssize_t bonding_show_bonds(struct class *cls, =
char *buf)
 		}
 		res +=3D sprintf(buf + res, "%s ", bond->dev->name);
 	}
-	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
+	if (res)
+		buf[res-1] =3D '\n'; /* eat the leftover space */
 	up_read(&(bonding_rwsem));
 	return res;
 }
@@ -239,7 +240,8 @@ static ssize_t bonding_show_slaves(struct device *d=
,
 		res +=3D sprintf(buf + res, "%s ", slave->dev->name);
 	}
 	read_unlock(&bond->lock);
-	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
+	if (res)
+		buf[res-1] =3D '\n'; /* eat the leftover space */
 	return res;
 }
=20
@@ -705,7 +707,8 @@ static ssize_t bonding_show_arp_targets(struct devi=
ce *d,
 			res +=3D sprintf(buf + res, "%u.%u.%u.%u ",
 			       NIPQUAD(bond->params.arp_targets[i]));
 	}
-	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
+	if (res)
+		buf[res-1] =3D '\n'; /* eat the leftover space */
 	return res;
 }
=20
--=20
1.4.4.4
