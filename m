From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Mon, 16 Sep 2002 16:43:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020916.164343.128145825.davem@redhat.com>
References: <3D86645F.5030401@mandrakesoft.com>
	<20020916.160210.70782700.davem@redhat.com>
	<3D866DD5.4080207@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, linux-kernel@vger.kernel.org, todd-lkml@osogrande.com,
   hadi@cyberus.ca, tcw@tempest.prismnet.com, netdev@oss.sgi.com,
   pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@mandrakesoft.com
In-Reply-To: <3D866DD5.4080207@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@mandrakesoft.com>
   Date: Mon, 16 Sep 2002 19:48:37 -0400

   I dunno when it happened, but 2.5.x now returns EINVAL for all 
   file->file cases.
   
   In 2.4.x, if sendpage is NULL, file_send_actor in mm/filemap.c faked a 
   call to fops->write().
   In 2.5.x, if sendpage is NULL, EINVAL is unconditionally returned.
   

What if source and destination file and offsets match?
Sounds like 2.4.x might deadlock.

In fact it sounds similar to the "read() with buf pointed to same
page in MAP_WRITE mmap()'d area" deadlock we had ages ago.
