From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: copybreak and gige network drivers
Date: Mon, 29 Sep 2003 14:25:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F787908.7000305@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I'm looking at doing some work on a driver for the gige portion of the 
Marvell Disco2.

The existing driver allocates mtu-sized buffers and always passes them 
off to the network stack.  I'm thinking about adding some copybreak 
optimizations, but I'm not sure what value I should use for the 
copybreak.  I would expect most packets to be on the smaller side.

Any suggestions?

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
