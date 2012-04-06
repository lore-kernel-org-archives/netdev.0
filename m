From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 0/2] update memcg to break its need of populate
Date: Fri,  6 Apr 2012 20:04:08 +0400
Message-ID: <1333728250-14248-1-git-send-email-glommer@parallels.com>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun and Li,

I am reposting the same series I've posted recently, just rebased
(two minor conflits) ontop of your last tree.

Let me know if this is acceptable.

Glauber Costa (2):
  cgroup: pass struct mem_cgroup instead of struct cgroup to socket
    memcg
  cgroup: get rid of populate for memcg

 include/net/sock.h           |   12 ++++++------
 include/net/tcp_memcontrol.h |    4 ++--
 mm/memcontrol.c              |   32 ++++++++++----------------------
 net/core/sock.c              |   10 +++++-----
 net/ipv4/tcp_memcontrol.c    |    6 ++----
 5 files changed, 25 insertions(+), 39 deletions(-)

-- 
1.7.7.6
