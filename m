From: "imperishablealbeit" <imperishablealbeit@163.com>
Subject: how to control the limited cpu resource for actions of transimiting packets from different interface?
Date: Tue, 12 Apr 2005 15:23:27 +0000 (UTC)
Message-ID: <200504121523.j3CFN4S3028078@oss.sgi.com>
Reply-To: imperishablealbeit@163.com
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 13 Apr 2005 23:22:35 -0800
To: "netdev" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,everyone, 

I meet a problem recently , the situation likes this:

there are two net card in my laptop, one is wired eth0 and the other is wireless netcard named eth1 . Now I have wroten a script like NAT, that is , the packats from eth0 the forward to  eth1, and the packets from eth1 also will be sent to eth0, so my laptop seems like a AP. What's more, there are two kinds of packets in the direction from etho to eth1, packet0 and packe1 alternatively. In order to meet the need of special requirement, packet0 must be sent with precedence over packet1,  so at any time, the packet0 should be deal with first. How can I deal with it in kernel?

I do not know if I can view the two actions, the one is transmiting packet0 from eth0 to eth1 and the other one is transmiting packet1  in the same direction, as two processes and schedule them with different priority ? if not , what I can arrvie at my aim in kernel?
is there any way particular ?? 

In addition, given that the whole CPU resource is unchangeable, in linux kernel how it can get balance point among actions such as the two presented above and 'who' can control it, a Daemon or 'someone else'?

I don't know how kernel works clearly and any help will be appreciated:) 

thanks !!
