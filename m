From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Thu, 7 Nov 2002 22:26:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15818.55916.259489.688198@robur.slu.se>
References: <Pine.GSO.4.30.0211070823590.11358-100000@shell.cyberus.ca>
	<Pine.LNX.4.44.0211071013150.31376-100000@grok.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Ben Greear <greearb@candelatech.com>,
   Donald Becker <becker@scyld.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: greear@candelatech.com
In-Reply-To: <Pine.LNX.4.44.0211071013150.31376-100000@grok.yi.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


greear@candelatech.com writes:
 > On Thu, 7 Nov 2002, jamal wrote:
 > > Trash the machines harder. Try using smaller packets;
 > 
 > They are already dropping packets, I thought I'd try to get a slower run 
 > to work cleanly before trying something faster.  Precision is more
 > important to me than absolute throughput at this point.


 If you need excessive buffering this gives latency and jitter which is 
 considered bad for network protocols and worse for test equipment.
 
 > Initial run with 256 sized rx-ring (and skb-recycle) shows better
 > performance (than with 1024 rx-ring)
 
 Packet size? Expect eventual effects when there is very high pressure on 
 the packet memory system. 

 
 Cheers.
					--ro
