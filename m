From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Mon, 16 Sep 2002 15:46:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020916.154640.78359545.davem@redhat.com>
References: <20020916.125211.82482173.davem@redhat.com>
	<Pine.LNX.4.44.0209161528140.13850-100000@gp.staff.osogrande.com>
	<12116.1032216780@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, todd-lkml@osogrande.com, hadi@cyberus.ca,
   tcw@tempest.prismnet.com, netdev@oss.sgi.com, pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: dwmw2@infradead.org
In-Reply-To: <12116.1032216780@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: David Woodhouse <dwmw2@infradead.org>
   Date: Mon, 16 Sep 2002 23:53:00 +0100
   
   Er, surely the same goes for sys_sendfile? Why have a new system call 
   rather than just swapping the 'in' and 'out' fds?

There is an assumption that one is a linear stream of output (in this
case a socket) and the other one is a page cache based file.

It would be nice to extend sys_sendfile to work properly in both
ways in a manner that Linus would accept, want to work on that?
