From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.4 SCTP fixes
Date: Wed, 18 Feb 2004 15:15:46 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402181456510.20485@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

I have updated lksctp 2.4 BK tree to 2.4.25 and pulled in the SCTP
csets that were excluded by Marcelo due to the config problem.

On top of this, the following 2 patches are applied.
- Revert to kmalloc() for ssnmap allocs of < 128K
- Fix syntax errors in net/sctp/Config.in

I am not pushing in the Config patch that will force enable crypto options
needed by SCTP as 'make xconfig' is having problems with this patch although
make oldconfig and make menuconfig seem to be OK.

Please pull these csets from
	http://linux-lksctp.bkbits.net/lksctp-2.4.work

ChangeSet@1.1329, 2004-02-18 14:17:28-08:00, sri@us.ibm.com
  [SCTP] Fix syntax errors in net/sctp Config.in.

ChangeSet@1.1328, 2004-02-18 12:03:04-08:00, sri@us.ibm.com
  Cset include: sri@us.ibm.com|ChangeSet|20040216054112|09098
  Cset include: sri@us.ibm.com|ChangeSet|20040213195328|09088
  Cset include: sri@us.ibm.com|ChangeSet|20040213011231|09074
  Cset include: sri@us.ibm.com|ChangeSet|20040213005510|09081
  Cset include: sri@us.ibm.com|ChangeSet|20040213003759|09793

ChangeSet@1.1327, 2004-02-18 11:58:13-08:00, sri@us.ibm.com
  Merge us.ibm.com:/home/sridhar/BK/linux-2.4
  into us.ibm.com:/home/sridhar/BK/lksctp-2.4.25

ChangeSet@1.1312.1.2, 2004-02-18 11:52:44-08:00, sri@us.ibm.com
  Cset exclude: sri@us.ibm.com|ChangeSet|20040216054112|09098

ChangeSet@1.1312.1.1, 2004-02-15 21:41:12-08:00, sri@us.ibm.com
  [SCTP] Revert back to use kmalloc() for ssnmap allocs of sizes < 128K

Thanks
Sridhar
