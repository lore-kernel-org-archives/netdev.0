From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: help???  trying to trace code path of outgoing udp packet
Date: Fri, 22 Aug 2003 08:36:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F46386A.4080009@us.ibm.com>
References: <3F46356A.804@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3F46356A.804@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:

> ip_finish_output     ip_output.c
> ip_finish_output2    ip_output.c   dst->neighbour->output

|
V
dev_queue_xmit()
qdisc_run()
qdisc_restart()
dev->hard_start_xmit() [driver xmit routine]

this is for the default queuing discipline.

thanks,
Nivedita
