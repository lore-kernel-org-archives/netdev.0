From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Mon, 16 Sep 2002 23:53:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <12116.1032216780@redhat.com>
References: <20020916.142931.126209536.davem@redhat.com>  <20020916.125211.82482173.davem@redhat.com> <Pine.LNX.4.44.0209161528140.13850-100000@gp.staff.osogrande.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, todd-lkml@osogrande.com, hadi@cyberus.ca,
   tcw@tempest.prismnet.com, netdev@oss.sgi.com, pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20020916.142931.126209536.davem@redhat.com> 
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


davem@redhat.com said:
>    new system calls into the networking code
> The system calls would go into the VFS, sys_receivefile is not
> networking specific in any way shape or form. 

Er, surely the same goes for sys_sendfile? Why have a new system call 
rather than just swapping the 'in' and 'out' fds?

--
dwmw2
