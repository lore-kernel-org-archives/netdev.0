From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: given a struct sock, how to find pid of process that owns it?
Date: Wed, 03 Sep 2003 13:17:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F562225.4010609@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I'm working on a small app similar to netstat that only cares about unix 
sockets.

I can easily walk /proc/net/unix, but to find the owner of the socket I 
need to scan /proc, which gets expensive.

Accordingly, I'd like to extend /proc/net/unix to also dump out the pid 
of the process that owns the socket.  The only thing is, I can't seem to 
figure out how to find the pid of the socket owner given a pointer to 
the socket struct.

Any tips?  Is it even there?

Thanks,

Chris


-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com	
