From: a.ranu@ugrad.unimelb.edu.au
Subject: window scaling
Date: Wed, 08 Oct 2003 17:03:27 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200310080703.h9873Rpm005797@cassius.its.unimelb.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi...

i am writing a module that modifies the advertised window in every outgoing 
packet with the help of ip connection tracking, if it is larger than the 
window i calculated (say x - not scaled, just in bytes)

would the following code be correct?

x_scaled = x >> (*pskb)->sk->tp_pinfo.af_tcp.rcv_wscale;
window_already_in_pkt = ntohs((*pskb)->h.th->window);

if (window_already_in_pkt > x_scaled)
	tcph->window = x_scaled;

a reply would be really appreciated

Asmeet.






-- 
a.ranu@ugrad.unimelb.edu.au
