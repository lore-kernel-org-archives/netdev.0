From: Alex de Landgraaf <alextreme@xs4all.nl>
Subject: [forcedeth] SET_NETDEV_DEV define
Date: Mon,  2 Feb 2004 01:47:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075682822.401d9e06885a0@am.xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hey guys,

Nice work on the forcedeth patches! I've been waiting for a nvnet alternative
for some time, and this seems to be it.

Anyway, in the forcedeth 2.4 v22 patch, it seems that forcedeth.c is missing the
#define SET_NETDEV_DEV from v20. Adding it is relativly simple, just wanted to
let you guys know that it doesn't compile on 2.4.23+ kernels (if you hadn't
heard this earlier).

from v20:
#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,5,70))
#define SET_NETDEV_DEV(x,y)   do { } while(0)
#endif

Could make a patch for it, but honestly I can't be bothered :)

It could also be that I got it completly wrong, in which case you can smack me
with the cluebat

Cheers and keep up with the good work,

/------------------------------------------------------------------\
| Alex de Landgraaf            | The cure for boredom is curiosity |
| Student AI & CS, VU, A'dam   |  There is no cure for curiosity   |
| Phone: 06-16844084           |                                   |
| GPG: http://am.xs4all.nl/key_alex.asc         /'-'\              |
| www.alextreme.org & www.morphix.org          ( o o )             |
\------------------------------------------oOO0--(_)--0OOo---------/
