From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: IMQ / new Dummy device post.
Date: Thu, 15 Apr 2004 10:42:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <407E5905.9070108@dsl.pipex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 >What am i looking for?
 >1) users and authors of IMQ to tell me if this achieves what IMQ >started
 >as. I have to say I DONT like the level of obstrutiveness from IMQ as >is
 >today. The code added by this is small (100 or less lines on top of
 >dummy) and doesnt touch any of the main core bits.
 >2) testing of the above by people who use IMQ
 >3) If someone has better ideas - i am not religious about keeping this;
 >but it certainly cant be the blasphemy that IMQ introduces

I am just a user and would drop IMQ without hesitation for something you 
consider more elegant, but I am not sure whether or not dummy will do 
what I want.

The only reason I use IMQ (+ NAT patch) is that I need to shape ingress 
(I know I can't shape it "properly" from the wrong end of the bottleneck 
without an intelligent app, but the ingress policer does not let me 
share local and forwarded bandwidth and is not fair per user if I just 
throttle the whole link).

I am not sure if dummy will sort this for me, there may be some other way?

Basically all I need is something I can use HTB on where the qos ingress 
box is on this diagram.

http://www.docum.org/stef.coene/qos/kptd/

Andy.
