From: Shridhar Kulkarni <shridhar@acceleratednetworks.com>
Subject: iproute2 question
Date: Tue, 14 May 2002 10:24:24 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <8B57A2E9423E844C911DF3BC5DB06E500FA146@CALVIN.acceleratednetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <owner-netdev@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

i am trying to send "iproute2 get" requests in async fashion to the
kernel.....i mean i send a new request to get new route even before i have
response to the earlier request...the "route get" implementation in iproute2
library is synchronous...it uses "rtnl_talk" routine and works great...i am
breaking it up for my application into "rtnl_send" and "rtnl_recv" for async
operation.....but it looks like i dont get responses for some of my
requests....any clues ????? 
