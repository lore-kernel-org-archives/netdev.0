From: "David S. Miller" <davem@redhat.com>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: Mon, 03 Mar 2003 10:56:46 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.105646.02089773.davem@redhat.com>
References: <3E6399F1.10303@nortelnetworks.com>
	<20030303.095641.87696857.davem@redhat.com>
	<3E63A8CB.2090307@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: terje.eggestad@scali.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com
In-Reply-To: <3E63A8CB.2090307@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Chris Friesen <cfriesen@nortelnetworks.com>
   Date: Mon, 03 Mar 2003 14:11:07 -0500
   
   I haven't done UDP bandwidth testing--I need to check how lmbench
   did it for the unix socket and do the same for UDP.  Local TCP was
   far slower than unix sockets though.

That result is system specific and depends upon how the data and
datastructures hit the cpu cachelines in the kernel.

TCP bandwidth is slightly faster than AF_UNIX bandwidth on my
sparc64 boxes for example.
