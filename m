From: Ben Greear <greearb@candelatech.com>
Subject: Question on TCP_INFO and retransmits.
Date: Thu, 29 Jul 2004 15:25:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4109795F.20300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The tcp_info structure that is available with getsockopt(...TCP_INFO)
has a tcpi_retransmits field and a tcpi_retrans field.

I was hoping that one of these would be monatomically incrementing
and keep track of all of the retransmits for the socket since it
was opened...

However, it appears that these counters are reset to zero fairly
often, making it difficult or impossible to use them to detect actual
TCP retransmits.

Is there some other way to detect the number of retransmitted packets?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
