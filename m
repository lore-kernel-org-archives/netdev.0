From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Mon, 16 Sep 2002 19:48:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D866DD5.4080207@mandrakesoft.com>
References: <12116.1032216780@redhat.com>	<12293.1032217399@redhat.com>	<3D86645F.5030401@mandrakesoft.com> <20020916.160210.70782700.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, linux-kernel@vger.kernel.org, todd-lkml@osogrande.com,
   hadi@cyberus.ca, tcw@tempest.prismnet.com, netdev@oss.sgi.com,
   pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@mandrakesoft.com>
>    Date: Mon, 16 Sep 2002 19:08:15 -0400
>    
>    I was rather disappointed when file->file sendfile was [purposefully?] 
>    broken in 2.5.x...
> 
> What change made this happen?


I dunno when it happened, but 2.5.x now returns EINVAL for all 
file->file cases.

In 2.4.x, if sendpage is NULL, file_send_actor in mm/filemap.c faked a 
call to fops->write().
In 2.5.x, if sendpage is NULL, EINVAL is unconditionally returned.
