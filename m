From: Andrea G Forte <andreaf@cs.columbia.edu>
Subject: Very slow change of IP in kernel (slow socket?).
Date: Tue, 21 Dec 2004 16:29:58 -0500
Message-ID: <41C895D6.2040001@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

after some talking I decided to try again and post a specific thread for 
this problem.
I noticed that when I change IP address for the same wireless card 
(since I am moving to a different subnet I need a new IP), the actual 
change in the kernel happens between 300 to 500 ms later. In particular, 
after changing the IP (ip route add...) and updating route table and 
default gw, the actual data packets are sent using the new IP only after 
300 to 500 ms after setting all the above.
Does anyone of you know what this could be related to? Or, does anyone 
of you know where in the kernel code I could start looking for some answers?
I have already had some feedback with suggestions to look into the 
route_cache, however this does not seem to me as a route problem but 
more as a socket problem and perhaps some kind of timer that is set to 
refresh the socket info in the kernel.

Any help would be really appreciated.

Thanks all,
Andrea
