From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: useability issue with iproute2 -- unexpected behaviour
Date: Thu, 12 Aug 2004 17:38:38 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411BE35E.6010406@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I tried running the command "ip ro del default table 100" on a system that did 
not have advanced routing support compiled in.

Let's just say I was kind of surprised when it took down the default route on 
the *main* routing table.

Is this expected behaviour?  I would expect some sort of error saying that 
routing table 100 was not accessable, or something similar.

Thanks,

Chris
