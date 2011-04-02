From: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Subject: nfs client doesn't work [was: mmotm 2011-03-31-14-48 uploaded]
Date: Sat, 02 Apr 2011 10:56:37 +0200
Message-ID: <4D96E4C5.2080302@suse.cz>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mm-commits-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201103312224.p2VMOA5g000983-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/31/2011 11:48 PM, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org wrote:
> The mm-of-the-moment snapshot 2011-03-31-14-48 has been uploaded to

Hi, nfs client is defunct in this kernel. Tcpdump says:
10:51:55.489717 IP 10.20.11.33.759945860 > 10.20.3.2.2049: 132 getattr
fh 0,0/24
10:51:55.515927 IP 10.20.3.2.2049 > 10.20.11.33.759945860: reply ok 44
getattr ERROR: Operation not permitted
10:51:55.515949 IP 10.20.11.33.921 > 10.20.3.2.2049: Flags [.], ack
3569361440, win 115, options [nop,nop,TS val 599750 ecr 255058541], length 0
10:52:04.130310 IP 10.20.11.33.793500292 > 10.20.3.2.2049: 76 getattr fh
0,0/24
10:52:04.152178 IP 10.20.3.2.2049 > 10.20.11.33.793500292: reply ok 44
getattr ERROR: Operation not permitted

If I run the same mount command (mount -oro,intr host:dir mountpoint)
from within a virtual machine with 2.6.38.2 there, everything mounts OK.

thanks,
-- 
js
suse labs
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
