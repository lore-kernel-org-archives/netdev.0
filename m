From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: help???  trying to trace code path of outgoing udp packet
Date: Fri, 22 Aug 2003 12:52:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F464A3E.2050203@nortelnetworks.com>
References: <3F46356A.804@nortelnetworks.com> <3F46386A.4080009@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> Chris Friesen wrote:
> 
>> ip_finish_output     ip_output.c
>> ip_finish_output2    ip_output.c   dst->neighbour->output
> 
> 
> |
> V
> dev_queue_xmit()
> qdisc_run()
> qdisc_restart()
> dev->hard_start_xmit() [driver xmit routine]
> 
> this is for the default queuing discipline.

Thanks.  That should give me enough to track down what I'm looking for.

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
