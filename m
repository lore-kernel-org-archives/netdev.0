From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Mon, 16 Sep 2002 19:08:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D86645F.5030401@mandrakesoft.com>
References: <20020916.154640.78359545.davem@redhat.com>  <20020916.125211.82482173.davem@redhat.com> <Pine.LNX.4.44.0209161528140.13850-100000@gp.staff.osogrande.com> <12116.1032216780@redhat.com> <12293.1032217399@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   todd-lkml@osogrande.com, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   netdev@oss.sgi.com, pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> davem@redhat.com said:
> 
>>>  Er, surely the same goes for sys_sendfile? Why have a new system
>>>  call rather than just swapping the 'in' and 'out' fds?
>>
> 
>>There is an assumption that one is a linear stream of output (in this
>>case a socket) and the other one is a page cache based file.
> 
> 
> That's an implementation detail and it's not clear we should be exposing it 
> to the user. It's not entirely insane to contemplate socket->socket or 
> file->file sendfile either -- would we invent new system calls for those 
> too? File descriptors are file descriptors.

I was rather disappointed when file->file sendfile was [purposefully?] 
broken in 2.5.x...

	Jeff
