From: David Laight <David.Laight@ACULAB.COM>
Subject: Does NetworkManager kill IPv6 connections?
Date: Thu, 4 Sep 2014 14:47:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174876CB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55707 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751449AbaIDOsX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:48:23 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22412-08 for <netdev@vger.kernel.org>;
 Thu,  4 Sep 2014 15:48:13 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was running a overnight test that failed because an (almost idle) IPv6 connection
unexpectedly disconnected.
30 seconds before the disconnect syslog contains (retyped):
  NetworkManager[pid]: <info> policy set 'Wired connection 2' (eth0) as default for IPv6 routing and DNS.
The same message appeared exactly 70 minutes earlier - with no ill effect.
A second connection between the same pair if addresses (carrying a lot of traffic)
was unaffected.

Any idea what/why NetworkManager is doing?
(Yes I know it is userspace, but it seems to be breaking the kernel....)

The system is an ubuntu 13.04 desktop (3.8.0-19 kernel), that recent, but
newer than the ones a lot of our customers use.

I can rerun the test, but don't know what to look for.
'eth0' is the only ethernet interface in the system that is actually
connected to a network.

Some indications of where to look would be appreciated.

	David
