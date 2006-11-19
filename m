From: Stephen Hemminger <shemminger@osdl.org>
Subject: [Fwd: [Bug 7551] New: Fluctuating and slow network perfomance]
Date: Sun, 19 Nov 2006 09:51:07 -0800
Message-ID: <4560998B.4000407@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090500070709050305050407"
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:23211 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932467AbWKSRvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 12:51:06 -0500
Received: from [192.168.0.110] (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id kAJHp3iw029950
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 19 Nov 2006 09:51:04 -0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090500070709050305050407
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------090500070709050305050407
Content-Type: message/rfc822;
 name="[Bug 7551] New: Fluctuating and slow network perfomance"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="[Bug 7551] New: Fluctuating and slow network perfomance"

Return-Path: <www@osdl.org>
Received: from smtp.osdl.org (smtp.osdl.org [65.172.181.25])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id kAJFEEka009238
	for <shemminger@mail.gateway.osdl.net>; Sun, 19 Nov 2006 07:14:14 -0800
Received: from fire-2.osdl.org (localhost [127.0.0.1])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id kAJFE8ix020411
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <shemminger@osdl.org>; Sun, 19 Nov 2006 07:14:08 -0800
Received: (from www@localhost)
	by fire-2.osdl.org (8.12.8/8.12.5/Submit) id kAJFE7Yd020409;
	Sun, 19 Nov 2006 07:14:07 -0800
Date: Sun, 19 Nov 2006 07:14:07 -0800
Message-Id: <200611191514.kAJFE7Yd020409@fire-2.osdl.org>
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@osdl.org
Subject: [Bug 7551] New: Fluctuating and slow network perfomance
X-Bugzilla-Reason: AssignedTo
X-Bugzilla-Category: Networking
X-Bugzilla-Component: IPV4
Received-SPF: pass (localhost is always allowed.)
X-Spam-Status: No, hits=0 required=5 tests=AWL,NO_REAL_NAME,OSDL_HEADER_SUBJECT_BRACKETED
X-Spam-Checker-Version: SpamAssassin 2.63-osdl_revision__1.105__
X-MIMEDefang-Filter: osdl$Revision: 1.159 $
X-Scanned-By: MIMEDefang 2.36

http://bugzilla.kernel.org/show_bug.cgi?id=7551

           Summary: Fluctuating and slow network perfomance
    Kernel Version: 2.6.18.x
            Status: NEW
          Severity: high
             Owner: shemminger@osdl.org
         Submitter: c.gm@usa.net


Most recent kernel where this bug did *NOT* occur:
2.6.17.13

Distribution:
Crux

Hardware Environment:
Seem not dependence tested om Intel P4 PII and AMD Optron based. We use Intel or
3com NIC the problem seem to be the same regardels wich nic it runs through.

Software Environment:
Pure linux router with iptables or as filserver with samba.
Teste also on server with Apache and singel NIC, but same issue.

Problem Description:
Since 2.18.X it seem to be problem with the network performance.
This problem might have been for a while but it come more obvious now when I
updated the Main router. The trafik is now much slower even testing local
between to machines with same kernel version. 
I tested between mashine with older kernel with same network connection, this
show normal transfer speed and ping.

Steps to reproduce:
I have tested on non loaded local network.

THIS IS PART OF THE PROBLEM
Ping is flutuating, no other traffic to from the mashine during test. 
The test are made between two 2.6.18.3 servers.
664 octets from 192.168.117.254: icmp_seq=0 ttl=64 time=9.3 ms
64 octets from 192.168.117.254: icmp_seq=1 ttl=64 time=0.2 ms
64 octets from 192.168.117.254: icmp_seq=2 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=3 ttl=64 time=1.3 ms
64 octets from 192.168.117.254: icmp_seq=4 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=5 ttl=64 time=0.2 ms
64 octets from 192.168.117.254: icmp_seq=6 ttl=64 time=0.2 ms
64 octets from 192.168.117.254: icmp_seq=7 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=8 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=9 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=10 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=11 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=12 ttl=64 time=1.3 ms
64 octets from 192.168.117.254: icmp_seq=13 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=14 ttl=64 time=0.2 ms
64 octets from 192.168.117.254: icmp_seq=15 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=16 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=17 ttl=64 time=1.2 ms
64 octets from 192.168.117.254: icmp_seq=18 ttl=64 time=0.2 ms
64 octets from 192.168.117.254: icmp_seq=19 ttl=64 time=0.2 ms
64 octets from 192.168.117.254: icmp_seq=20 ttl=64 time=0.1 ms
64 octets from 192.168.117.254: icmp_seq=21 ttl=64 time=0.2 ms
64 octets from 192.168.117.254: icmp_seq=22 ttl=64 time=0.2 ms
64 octets from 192.168.117.254: icmp_seq=23 ttl=64 time=1.3 ms
64 octets from 192.168.117.254: icmp_seq=24 ttl=64 time=1.3 ms

This is between 2 2.6.17.13
This is very normal ping for our network.
64 octets from 192.168.117.229: icmp_seq=0 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=1 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=2 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=3 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=4 ttl=64 time=0.0 ms
64 octets from 192.168.117.229: icmp_seq=5 ttl=64 time=0.0 ms
64 octets from 192.168.117.229: icmp_seq=6 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=7 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=8 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=9 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=10 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=11 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=12 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=13 ttl=64 time=0.0 ms
64 octets from 192.168.117.229: icmp_seq=14 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=15 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=16 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=17 ttl=64 time=0.0 ms
64 octets from 192.168.117.229: icmp_seq=18 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=19 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=20 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=21 ttl=64 time=0.2 ms
64 octets from 192.168.117.229: icmp_seq=22 ttl=64 time=0.0 ms
64 octets from 192.168.117.229: icmp_seq=23 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=24 ttl=64 time=0.1 ms
64 octets from 192.168.117.229: icmp_seq=25 ttl=64 time=0.1 ms


COPY TEST:
Are general made between ramddisk
I have use both scp and other copy method, like SAMBA and NFS but the problem
are simmular, use the result from scp test.

TEST 1
This is between two server with kernel 2.6.17.13
scp sysop@229.ndc:/usr/src/linux-2.6.18.3.tar.bz2 /home/sysop
sysop@229.ndc's password:
linux-2.6.18.3.tar.bz2                                                         
      100%   40MB  13.3MB/s   00:03
The same speed all time

TEST 2
This is between two server with kernel 2.6.16.7 and 2.6.17.13
scp sysop@229.ndc:/usr/src/linux-2.6.18.3.tar.bz2 /home/sysop
sysop@229.ndc's password:
linux-2.6.18.3.tar.bz2                                                         
      100%   40MB  10.0MB/s   00:04
Same speed all the time

TEST 3
HERE IS PROBLEM SHOWN
This is between two server with kernel 2.6.18.3 
The speed fluctuate
scp sysop@217.25.252.230:/usr/src/linux-2.6.18.1.tar.bz2 /home/sysop
sysop@217.25.252.230's password:
linux-2.6.18.1.tar.bz2                                                         
      100%   40MB   8.0MB/s   00:05

TEST 3a
scp sysop@217.25.252.230:/usr/src/linux-2.6.18.1.tar.bz2 /home/sysop
sysop@217.25.252.230's password:
linux-2.6.18.1.tar.bz2                                                         
      100%   40MB   4.6MB/s   00:09

TEST 3b
scp sysop@217.25.252.230:/usr/src/linux-2.6.18.1.tar.bz2 /home/sysop
sysop@217.25.252.230's password:
linux-2.6.18.1.tar.bz2                                                         
      100%   40MB   7.6MB/s   00:07

Test 4a
This is between two other server with kernel 2.6.18.3 but two other machine
differnt NIC.

scp sysop@77.ndc:/usr/src/linux-2.6.17.13.tar.bz2 /home/sysop
sysop@77.ndc's password:
linux-2.6.17.13.tar.bz2                                                        
      100%   39MB   7.9MB/s   00:05

Test 4a
scp sysop@77.ndc:/usr/src/linux-2.6.17.13.tar.bz2 /home/sysop
sysop@77.ndc's password:
linux-2.6.17.13.tar.bz2                                                        
      
100%   39MB   6.6MB/s   00:06

Im not a programmer, so I can't go more deep down to the problem than this.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

--------------090500070709050305050407--
