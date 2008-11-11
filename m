From: Dave Jones <davej@redhat.com>
Subject: Fwd: [Bug 470774] New: [RFC1981-PMTU]Multicast Destination - One
	Router test failed
Date: Tue, 11 Nov 2008 12:42:32 -0500
Message-ID: <20081111174232.GA32434@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Cc: jiabwang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36399 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706AbYKKRmf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 12:42:35 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mABHgYVl006478
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 12:42:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hopefully this makes more sense to the networking developers
than it does to me.

	Dave

-- 
http://www.codemonkey.org.uk

--fUYQa+Pmc3FrFX/N
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: kernel-maint-bounces@redhat.com
X-Spam-Checker-Version: SpamAssassin 3.2.5 (2008-06-10) on
	gelk.kernelslacker.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=5.0 tests=AWL,BAYES_00,
	UNPARSEABLE_RELAY autolearn=ham version=3.2.5
Received: from mail.corp.redhat.com [10.5.5.53]
	by gelk.kernelslacker.org with IMAP (fetchmail-6.3.8)
	for <davej@localhost> (single-drop); Mon, 10 Nov 2008 01:47:31 -0500 (EST)
Received: from zmta03.collab.prod.int.phx2.redhat.com (LHLO
 zmta03.collab.prod.int.phx2.redhat.com) (10.5.5.33) by
 mail01.corp.redhat.com with LMTP; Mon, 10 Nov 2008 01:02:02 -0500 (EST)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zmta03.collab.prod.int.phx2.redhat.com (Postfix) with ESMTP id F32404C07B;
	Mon, 10 Nov 2008 01:02:01 -0500 (EST)
Received: from zmta03.collab.prod.int.phx2.redhat.com ([127.0.0.1])
	by localhost (zmta03.collab.prod.int.phx2.redhat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XDglc6+WkpP1; Mon, 10 Nov 2008 01:02:01 -0500 (EST)
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by zmta03.collab.prod.int.phx2.redhat.com (Postfix) with ESMTP id 9A3D84C049;
	Mon, 10 Nov 2008 01:02:01 -0500 (EST)
Received: from post-office.corp.redhat.com (post-office.corp.redhat.com [10.11.254.111])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mAA620Mb013813;
	Mon, 10 Nov 2008 01:02:00 -0500
Received: from post-office.corp.redhat.com (localhost.localdomain [127.0.0.1])
	by post-office.corp.redhat.com (8.13.8/8.13.8) with ESMTP id mAA6200S015007;
	Mon, 10 Nov 2008 01:02:00 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254] (may be forged))
	by post-office.corp.redhat.com (8.13.8/8.13.8) with ESMTP id
	mAA61xgm014996 for <kernel-maint@post-office.corp.redhat.com>;
	Mon, 10 Nov 2008 01:01:59 -0500
Received: from mx2.util.phx.redhat.com (mx2.util.phx.redhat.com [10.8.4.102])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id
	mAA61vI4001893 for <kernel-maint@int-mx1.corp.redhat.com>;
	Mon, 10 Nov 2008 01:01:58 -0500
Received: from bz-web2.app.phx.redhat.com (nat-pool.util.phx.redhat.com
	[10.8.5.200])
	by mx2.util.phx.redhat.com (8.13.1/8.13.1) with ESMTP id mAA61v2U004538
	for <kernel-maint@redhat.com>; Mon, 10 Nov 2008 01:01:57 -0500
Received: from bz-web2.app.phx.redhat.com (localhost.localdomain [127.0.0.1])
	by bz-web2.app.phx.redhat.com (8.13.8/8.13.8) with ESMTP id
	mAA61uGu022284
	for <kernel-maint@redhat.com>; Mon, 10 Nov 2008 01:01:57 -0500
Received: (from apache@localhost)
	by bz-web2.app.phx.redhat.com (8.13.8/8.13.8/Submit) id mAA5v8XX021402;
	Mon, 10 Nov 2008 00:57:08 -0500
Date: Mon, 10 Nov 2008 00:57:08 -0500
X-Authentication-Warning: bz-web2.app.phx.redhat.com: apache set sender to
	bugzilla@redhat.com using -f
From: bugzilla@redhat.com
To: kernel-maint@redhat.com
Subject: [Bug 470774] New: [RFC1981-PMTU]Multicast Destination - One Router
	test failed
X-Loop: bugzilla@redhat.com
X-BeenThere: bugzilla@redhat.com
X-Bugzilla-Reason: CC AssignedTo
X-Bugzilla-Type: newchanged
X-Bugzilla-Watch-Reason: None
X-Bugzilla-Classification: Fedora
X-Bugzilla-Product: Fedora
X-Bugzilla-Version: rawhide
X-Bugzilla-Component: kernel
X-Bugzilla-Keywords: 
X-Bugzilla-Severity: medium
X-Bugzilla-Comment: Public
X-Bugzilla-Who: jiabwang@redhat.com
X-Bugzilla-Status: NEW
X-Bugzilla-Priority: medium
X-Bugzilla-Assigned-To: kernel-maint@redhat.com
X-Bugzilla-Target-Milestone: ---
X-Bugzilla-Changed-Fields: 
Message-ID: <bug-470774-176318@bugzilla.redhat.com>
Auto-Submitted: auto-generated
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.58 on 172.16.27.26
X-Scanned-By: MIMEDefang 2.58 on 172.16.52.254
X-BeenThere: kernel-maint@redhat.com
X-Mailman-Version: 2.1.9
Precedence: list
List-Id: <kernel-maint.redhat.com>
List-Unsubscribe: <http://post-office.corp.redhat.com/mailman/listinfo/kernel-maint>,
	<mailto:kernel-maint-request@redhat.com?subject=unsubscribe>
List-Archive: <http://post-office.corp.redhat.com/mailman/private/kernel-maint>
List-Post: <mailto:kernel-maint@redhat.com>
List-Help: <mailto:kernel-maint-request@redhat.com?subject=help>
List-Subscribe: <http://post-office.corp.redhat.com/mailman/listinfo/kernel-maint>,
	<mailto:kernel-maint-request@redhat.com?subject=subscribe>
Sender: kernel-maint-bounces@redhat.com
Errors-To: kernel-maint-bounces@redhat.com

Please do not reply directly to this email. All additional
comments should be made in the comments box of this bug.

Summary: [RFC1981-PMTU]Multicast Destination - One Router test failed

https://bugzilla.redhat.com/show_bug.cgi?id=470774

           Summary: [RFC1981-PMTU]Multicast Destination - One Router test
                    failed
           Product: Fedora
           Version: rawhide
          Platform: All
        OS/Version: Linux
            Status: NEW
          Severity: medium
          Priority: medium
         Component: kernel
        AssignedTo: kernel-maint@redhat.com
        ReportedBy: jiabwang@redhat.com
         QAContact: extras-qa@fedoraproject.org
                CC: llim@redhat.com, kernel-maint@redhat.com,
                    quintela@redhat.com
   Estimated Hours: 0.0
    Classification: Fedora


Description of problem:
TN(FreeBSD7) sends packet too big message to NUT(Fedora10) , 
NUT(Fedora10) cannot  receive  muticast echo request of fragment 


Version-Release number of selected component (if applicable):
2.6.27-0.352.rc7.git1.fc10.i686

How reproducible:
every time

Steps to Reproduce:
1.
2.
3.

Actual results:
Cannot receive Echo Request

Expected results:
Can receive Echo Request

Additional info:
failure  log info :
Start Capturing Packets (Link0)

 --- start Common Test Setup 1.1 for Host
09:58:52 vSend(Link0,setup_echo_request)
Send Echo Request (Link-Local)
09:58:52  vRecv(Link0,setup_echo_reply ns_l2l ns_g2l) timeout:5 cntLimit:0
seektime:0
Recv Neighbor Solicitation (Link-Local to Link-Local)
09:58:52 vSend(Link0,na_l2l)
Send Neighbor Advertisement (Link-Local to Link-Local)
09:58:52  vRecv(Link0,setup_echo_reply) timeout:5 cntLimit:0 seektime:0
Recv Echo Reply (Link-Local)

 OK
09:58:52 vSend(Link0,setup_ra)
Send Router Advertisement
09:58:52  vRecv(Link0,setup_dadns) timeout:5 cntLimit:0 seektime:0
Recv DADNS
09:58:52  Wait 5 second
09:58:57 vSend(Link0,setup_echo_request_g)
Send Echo Request (Global)
09:58:57  vRecv(Link0,setup_echo_reply_g ns_g2g ns_l2g) timeout:5 cntLimit:0
seektime:0
Recv Neighbor Solicitation (Global to Global)
09:58:57 vSend(Link0,na_g2g)
Send Neighbor Advertisement (Global to Global)
09:58:57  vRecv(Link0,setup_echo_reply_g) timeout:5 cntLimit:0 seektime:0
Recv Echo Reply (Global)

 OK
09:58:57 Clear Captured Packets (Link0)

 --- end Common Test Setup 1.1 for Host
NUT send 1st Echo Request to Multicast Destination
09:58:57 Clear Captured Packets (Link0)
09:58:57  vRemote(ping6.rmt) ``/usr/local/v6eval//bin/rhel51//ping6.rmt -t
rhel51 -u root -p redhat -d cuad0 -o 1 size=1452 addr=FF1E::1:2 if=eth1 ''

Connected
prompt_user: ``login: '', prompt_password: ``Password: '', prompt_command:
``(\$|#) ''
rLogin: Wait for login prompt (0.2 sec)...
rLogin: Never got prompt; try again
rLogin: Wait for login prompt (50 sec)...

Fedora release 9.91 (Rawhide)
Kernel 2.6.27-0.352.rc7.git1.fc10.i686 on an i686 (ttyS0)

ipv6test login: rLogin: Got login prompt
rlogin: wait for password prompt
rLogin: Wait for password prompt (50 sec)
root
Password: rLogin: Got password prompt
rLogin: Wait for command prompt (50 sec)

Last login: Mon Nov 10 09:56:12 on ttyS0
[root@ipv6test ~]# rLogin: Got command prompt
_rCommand: Try to get command prompt (0.2 sec.)
_rCommand: (\$|#) 
_rCommand: command prompt...
_rCommand: Try to get command prompt (15 sec.)
_rCommand: (\$|#) 

[root@ipv6test ~]# _rCommand: Do ``ping6 -n -c 1 -i 1 -s 1452 -p 00 -w 2 -I
eth1 FF1E::1:2'' command
ping6 -n -c 1 -i 1 -s 1452 -p 00 -w 2 -I eth1 FF1E::1:2
rCommand: Try to get command prompt (0.2 sec)
PATTERN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1452
data bytes
rCommand: Try to get command prompt (15 sec)


--- FF1E::1:2 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2000ms

[root@ipv6test ~]# 
[rootrCommand: CmdOutput=``
PATTERN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1452
data bytes


--- FF1E::1:2 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2000ms

[root@ipv6test ~]''
@ipv6test ~]# echo $?
1rCommand: exit status: 1
~
[EOT]

09:59:01  vRecv(Link0,u_ns_g2l_wo ns_l2l u_ns_l2l_wo u_ns_g2l u_ns_l2g_wo
ns_g2g ns_g2l u_ns_l2l u_ns_g2g u_ns_g2g_wo u_ns_l2g ns_l2g echo_request_mc1500
echo_request1500_1st_8 echo_request1500_1st_16 echo_request1500_1st_24
echo_request1500_1st_32 echo_request1500_1st_40 echo_request1500_1st_48
echo_request1500_1st_56 echo_request1500_1st_64 echo_request1500_1st_72
echo_request1500_1st_80 echo_request1500_1st_88 echo_request1500_1st_96
echo_request1500_1st_104 echo_request1500_1st_112 echo_request1500_1st_120
echo_request1500_1st_128 echo_request1500_1st_136 echo_request1500_1st_144
echo_request1500_1st_152 echo_request1500_1st_160 echo_request1500_1st_168
echo_request1500_1st_176 echo_request1500_1st_184 echo_request1500_1st_192
echo_request1500_1st_200 echo_request1500_1st_208 echo_request1500_1st_216
echo_request1500_1st_224 echo_request1500_1st_232 echo_request1500_1st_240
echo_request1500_1st_248 echo_request1500_1st_256 echo_request1500_1st_264
echo_request1500_1st_272 echo_request1500_1st_280 echo_request1500_1st_288
echo_request1500_1st_296 echo_request1500_1st_304 echo_request1500_1st_312
echo_request1500_1st_320 echo_request1500_1st_328 echo_request1500_1st_336
echo_request1500_1st_344 echo_request1500_1st_352 echo_request1500_1st_360
echo_request1500_1st_368 echo_request1500_1st_376 echo_request1500_1st_384
echo_request1500_1st_392 echo_request1500_1st_400 echo_request1500_1st_408
echo_request1500_1st_416 echo_request1500_1st_424 echo_request1500_1st_432
echo_request1500_1st_440 echo_request1500_1st_448 echo_request1500_1st_456
echo_request1500_1st_464 echo_request1500_1st_472 echo_request1500_1st_480
echo_request1500_1st_488 echo_request1500_1st_496 echo_request1500_1st_504
echo_request1500_1st_512 echo_request1500_1st_520 echo_request1500_1st_528
echo_request1500_1st_536 echo_request1500_1st_544 echo_request1500_1st_552
echo_request1500_1st_560 echo_request1500_1st_568 echo_request1500_1st_576
echo_request1500_1st_584 echo_request1500_1st_592 echo_request1500_1st_600
echo_request1500_1st_608 echo_request1500_1st_616 echo_request1500_1st_624
echo_request1500_1st_632 echo_request1500_1st_640 echo_request1500_1st_648
echo_request1500_1st_656 echo_request1500_1st_664 echo_request1500_1st_672
echo_request1500_1st_680 echo_request1500_1st_688 echo_request1500_1st_696
echo_request1500_1st_704 echo_request1500_1st_712 echo_request1500_1st_720
echo_request1500_1st_728 echo_request1500_1st_736 echo_request1500_1st_744
echo_request1500_1st_752 echo_request1500_1st_760 echo_request1500_1st_768
echo_request1500_1st_776 echo_request1500_1st_784 echo_request1500_1st_792
echo_request1500_1st_800 echo_request1500_1st_808 echo_request1500_1st_816
echo_request1500_1st_824 echo_request1500_1st_832 echo_request1500_1st_840
echo_request1500_1st_848 echo_request1500_1st_856 echo_request1500_1st_864
echo_request1500_1st_872 echo_request1500_1st_880 echo_request1500_1st_888
echo_request1500_1st_896 echo_request1500_1st_904 echo_request1500_1st_912
echo_request1500_1st_920 echo_request1500_1st_928 echo_request1500_1st_936
echo_request1500_1st_944 echo_request1500_1st_952 echo_request1500_1st_960
echo_request1500_1st_968 echo_request1500_1st_976 echo_request1500_1st_984
echo_request1500_1st_992 echo_request1500_1st_1000 echo_request1500_1st_1008
echo_request1500_1st_1016 echo_request1500_1st_1024 echo_request1500_1st_1032
echo_request1500_1st_1040 echo_request1500_1st_1048 echo_request1500_1st_1056
echo_request1500_1st_1064 echo_request1500_1st_1072 echo_request1500_1st_1080
echo_request1500_1st_1088 echo_request1500_1st_1096 echo_request1500_1st_1104
echo_request1500_1st_1112 echo_request1500_1st_1120 echo_request1500_1st_1128
echo_request1500_1st_1136 echo_request1500_1st_1144 echo_request1500_1st_1152
echo_request1500_1st_1160 echo_request1500_1st_1168 echo_request1500_1st_1176
echo_request1500_1st_1184 echo_request1500_1st_1192 echo_request1500_1st_1200
echo_request1500_1st_1208 echo_request1500_1st_1216 echo_request1500_1st_1224
echo_request1500_1st_1232 echo_request1500_1st_1240 echo_request1500_1st_1248
echo_request1500_1st_1256 echo_request1500_1st_1264 echo_request1500_1st_1272
echo_request1500_1st_1280 echo_request1500_1st_1288 echo_request1500_1st_1296
echo_request1500_1st_1304 echo_request1500_1st_1312 echo_request1500_1st_1320
echo_request1500_1st_1328 echo_request1500_1st_1336 echo_request1500_1st_1344
echo_request1500_1st_1352 echo_request1500_1st_1360 echo_request1500_1st_1368
echo_request1500_1st_1376 echo_request1500_1st_1384 echo_request1500_1st_1392
echo_request1500_1st_1400 echo_request1500_1st_1408 echo_request1500_1st_1416
echo_request1500_1st_1424 echo_request1500_1st_1432 echo_request1500_1st_1440
echo_request1500_1st_1448) timeout:5 cntLimit:0 seektime:0
Recv multicast Echo Request (Packet size is 1500)

 OK
09:59:01 vSend(Link0,PktTooBig)
Send Packet Too Big message

 NUT send 2nd Echo Request to Multicast Destination
09:59:01 Clear Captured Packets (Link0)
09:59:01  vRemote(ping6.rmt) ``/usr/local/v6eval//bin/rhel51//ping6.rmt -t
rhel51 -u root -p redhat -d cuad0 -o 1 size=1452 addr=FF1E::1:2 if=eth1 ''

Connected
prompt_user: ``login: '', prompt_password: ``Password: '', prompt_command:
``(\$|#) ''
rLogin: Wait for login prompt (0.2 sec)...
rLogin: Never got prompt; try again
rLogin: Wait for login prompt (50 sec)...

[root@ipv6test ~]# rLogin: Got command prompt
rLogin: Got command prompt
_rCommand: Try to get command prompt (0.2 sec.)
_rCommand: (\$|#) 
_rCommand: command prompt...
_rCommand: Try to get command prompt (15 sec.)
_rCommand: (\$|#) 

[root@ipv6test ~]# _rCommand: Do ``ping6 -n -c 1 -i 1 -s 1452 -p 00 -w 2 -I
eth1 FF1E::1:2'' command
ping6 -n -c 1 -i 1 -s 1452 -p 00 -w 2 -I eth1 FF1E::1:2
PATTErCommand: Try to get command prompt (0.2 sec)
RN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1452
data bytes
>From 3ffe:501:ffff:100:21d:fff:fe0f:be4e icmp_seq=1 Packet too big: mtu=1450

--- FF1E::1:2 ping statistics ---
0 packets transmitted, 0 received, +1 errors

[root@ipv6test ~]# rCommand: CmdOutput=``
PATTERN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1452
data bytes
>From 3ffe:501:ffff:100:21d:fff:fe0f:be4e icmp_seq=1 Packet too big: mtu=1450

--- FF1E::1:2 ping statistics ---
0 packets transmitted, 0 received, +1 errors

[root@ipv6test ~]''
echo $?
1
[roorCommand: exit status: 1
~
[EOT]

09:59:02  vRecv(Link0,u_ns_g2l_wo ns_l2l u_ns_g2l u_ns_l2l_wo ns_g2g
u_ns_l2g_wo u_ns_l2l ns_g2l u_ns_g2g u_ns_g2g_wo u_ns_l2g ns_l2g
echo_request1500_1st_64 echo_request1500_1st_72 echo_request1500_1st_80
echo_request1500_1st_88 echo_request1500_1st_96 echo_request1500_1st_104
echo_request1500_1st_112 echo_request1500_1st_120 echo_request1500_1st_128
echo_request1500_1st_136 echo_request1500_1st_144 echo_request1500_1st_152
echo_request1500_1st_160 echo_request1500_1st_168 echo_request1500_1st_176
echo_request1500_1st_184 echo_request1500_1st_192 echo_request1500_1st_200
echo_request1500_1st_208 echo_request1500_1st_216 echo_request1500_1st_224
echo_request1500_1st_232 echo_request1500_1st_240 echo_request1500_1st_248
echo_request1500_1st_256 echo_request1500_1st_264 echo_request1500_1st_272
echo_request1500_1st_280 echo_request1500_1st_288 echo_request1500_1st_296
echo_request1500_1st_304 echo_request1500_1st_312 echo_request1500_1st_320
echo_request1500_1st_328 echo_request1500_1st_336 echo_request1500_1st_344
echo_request1500_1st_352 echo_request1500_1st_360 echo_request1500_1st_368
echo_request1500_1st_376 echo_request1500_1st_384 echo_request1500_1st_392
echo_request1500_1st_400 echo_request1500_1st_408 echo_request1500_1st_416
echo_request1500_1st_424 echo_request1500_1st_432 echo_request1500_1st_440
echo_request1500_1st_448 echo_request1500_1st_456 echo_request1500_1st_464
echo_request1500_1st_472 echo_request1500_1st_480 echo_request1500_1st_488
echo_request1500_1st_496 echo_request1500_1st_504 echo_request1500_1st_512
echo_request1500_1st_520 echo_request1500_1st_528 echo_request1500_1st_536
echo_request1500_1st_544 echo_request1500_1st_552 echo_request1500_1st_560
echo_request1500_1st_568 echo_request1500_1st_576 echo_request1500_1st_584
echo_request1500_1st_592 echo_request1500_1st_600 echo_request1500_1st_608
echo_request1500_1st_616 echo_request1500_1st_624 echo_request1500_1st_632
echo_request1500_1st_640 echo_request1500_1st_648 echo_request1500_1st_656
echo_request1500_1st_664 echo_request1500_1st_672 echo_request1500_1st_680
echo_request1500_1st_688 echo_request1500_1st_696 echo_request1500_1st_704
echo_request1500_1st_712 echo_request1500_1st_720 echo_request1500_1st_728
echo_request1500_1st_736 echo_request1500_1st_744 echo_request1500_1st_752
echo_request1500_1st_760 echo_request1500_1st_768 echo_request1500_1st_776
echo_request1500_1st_784 echo_request1500_1st_792 echo_request1500_1st_800
echo_request1500_1st_808 echo_request1500_1st_816 echo_request1500_1st_824
echo_request1500_1st_832 echo_request1500_1st_840 echo_request1500_1st_848
echo_request1500_1st_856 echo_request1500_1st_864 echo_request1500_1st_872
echo_request1500_1st_880 echo_request1500_1st_888 echo_request1500_1st_896
echo_request1500_1st_904 echo_request1500_1st_912 echo_request1500_1st_920
echo_request1500_1st_928 echo_request1500_1st_936 echo_request1500_1st_944
echo_request1500_1st_952 echo_request1500_1st_960 echo_request1500_1st_968
echo_request1500_1st_976 echo_request1500_1st_984 echo_request1500_1st_992
echo_request1500_1st_1000 echo_request1500_1st_1008 echo_request1500_1st_1016
echo_request1500_1st_1024 echo_request1500_1st_1032 echo_request1500_1st_1040
echo_request1500_1st_1048 echo_request1500_1st_1056 echo_request1500_1st_1064
echo_request1500_1st_1072 echo_request1500_1st_1080 echo_request1500_1st_1088
echo_request1500_1st_1096 echo_request1500_1st_1104 echo_request1500_1st_1112
echo_request1500_1st_1120 echo_request1500_1st_1128 echo_request1500_1st_1136
echo_request1500_1st_1144 echo_request1500_1st_1152 echo_request1500_1st_1160
echo_request1500_1st_1168 echo_request1500_1st_1176 echo_request1500_1st_1184
echo_request1500_1st_1192 echo_request1500_1st_1200 echo_request1500_1st_1208
echo_request1500_1st_1216 echo_request1500_1st_1224 echo_request1500_1st_1232
echo_request1500_1st_1240 echo_request1500_1st_1248 echo_request1500_1st_1256
echo_request1500_1st_1264 echo_request1500_1st_1272 echo_request1500_1st_1280
echo_request1500_1st_1288 echo_request1500_1st_1296 echo_request1500_1st_1304
echo_request1500_1st_1312 echo_request1500_1st_1320 echo_request1500_1st_1328
echo_request1500_1st_1336 echo_request1500_1st_1344 echo_request1500_1st_1352
echo_request1500_1st_1360 echo_request1500_1st_1368 echo_request1500_1st_1376
echo_request1500_1st_1384 echo_request1500_1st_1392 echo_request1500_1st_1400)
timeout:5 cntLimit:0 seektime:0
vRecv() return status=1

 Cannot receive Echo Request
NG
09:59:07 vSend(Link0,PktTooBig_others)
Send Packet Too Big message

 NUT send 3rd Echo Request to Multicast Destination
09:59:08 Clear Captured Packets (Link0)
09:59:08  vRemote(ping6.rmt) ``/usr/local/v6eval//bin/rhel51//ping6.rmt -t
rhel51 -u root -p redhat -d cuad0 -o 1 size=1452 addr=FF1E::1:2 if=eth1 ''

Connected
prompt_user: ``login: '', prompt_password: ``Password: '', prompt_command:
``(\$|#) ''
rLogin: Wait for login prompt (0.2 sec)...
rLogin: Never got prompt; try again
rLogin: Wait for login prompt (50 sec)...

[root@ipv6test ~]# rLogin: Got command prompt
rLogin: Got command prompt
_rCommand: Try to get command prompt (0.2 sec.)
_rCommand: (\$|#) 
_rCommand: command prompt...
_rCommand: Try to get command prompt (15 sec.)
_rCommand: (\$|#) 

[root@ipv6test ~]# _rCommand: Do ``ping6 -n -c 1 -i 1 -s 1452 -p 00 -w 2 -I
eth1 FF1E::1:2'' command
ping6 -n -c 1 -i 1 -s 1452 -p 00 -w 2 -I eth1 FF1E::1:2
PATTErCommand: Try to get command prompt (0.2 sec)
RN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1452
data bytes
>From 3ffe:501:ffff:100:21d:fff:fe0f:be4e icmp_seq=1 Packet too big: mtu=1400

--- FF1E::1:2 ping statistics ---
0 packets transmitted, 0 received, +1 errors

[root@ipv6test rCommand: Try to get command prompt (15 sec)
~]# 
[rorCommand: CmdOutput=``
PATTERN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1452
data bytes
>From 3ffe:501:ffff:100:21d:fff:fe0f:be4e icmp_seq=1 Packet too big: mtu=1400

--- FF1E::1:2 ping statistics ---
0 packets transmitted, 0 received, +1 errors

[root@ipv6test ~]''
ot@ipv6test ~]# echo $?
1
[rCommand: exit status: 1
~
[EOT]

09:59:09  vRecv(Link0,u_ns_g2l_wo ns_l2l u_ns_g2l u_ns_l2l_wo ns_g2g
u_ns_l2g_wo u_ns_l2l ns_g2l u_ns_g2g u_ns_g2g_wo u_ns_l2g ns_l2g
echo_request1500_1st_112 echo_request1500_1st_120 echo_request1500_1st_128
echo_request1500_1st_136 echo_request1500_1st_144 echo_request1500_1st_152
echo_request1500_1st_160 echo_request1500_1st_168 echo_request1500_1st_176
echo_request1500_1st_184 echo_request1500_1st_192 echo_request1500_1st_200
echo_request1500_1st_208 echo_request1500_1st_216 echo_request1500_1st_224
echo_request1500_1st_232 echo_request1500_1st_240 echo_request1500_1st_248
echo_request1500_1st_256 echo_request1500_1st_264 echo_request1500_1st_272
echo_request1500_1st_280 echo_request1500_1st_288 echo_request1500_1st_296
echo_request1500_1st_304 echo_request1500_1st_312 echo_request1500_1st_320
echo_request1500_1st_328 echo_request1500_1st_336 echo_request1500_1st_344
echo_request1500_1st_352 echo_request1500_1st_360 echo_request1500_1st_368
echo_request1500_1st_376 echo_request1500_1st_384 echo_request1500_1st_392
echo_request1500_1st_400 echo_request1500_1st_408 echo_request1500_1st_416
echo_request1500_1st_424 echo_request1500_1st_432 echo_request1500_1st_440
echo_request1500_1st_448 echo_request1500_1st_456 echo_request1500_1st_464
echo_request1500_1st_472 echo_request1500_1st_480 echo_request1500_1st_488
echo_request1500_1st_496 echo_request1500_1st_504 echo_request1500_1st_512
echo_request1500_1st_520 echo_request1500_1st_528 echo_request1500_1st_536
echo_request1500_1st_544 echo_request1500_1st_552 echo_request1500_1st_560
echo_request1500_1st_568 echo_request1500_1st_576 echo_request1500_1st_584
echo_request1500_1st_592 echo_request1500_1st_600 echo_request1500_1st_608
echo_request1500_1st_616 echo_request1500_1st_624 echo_request1500_1st_632
echo_request1500_1st_640 echo_request1500_1st_648 echo_request1500_1st_656
echo_request1500_1st_664 echo_request1500_1st_672 echo_request1500_1st_680
echo_request1500_1st_688 echo_request1500_1st_696 echo_request1500_1st_704
echo_request1500_1st_712 echo_request1500_1st_720 echo_request1500_1st_728
echo_request1500_1st_736 echo_request1500_1st_744 echo_request1500_1st_752
echo_request1500_1st_760 echo_request1500_1st_768 echo_request1500_1st_776
echo_request1500_1st_784 echo_request1500_1st_792 echo_request1500_1st_800
echo_request1500_1st_808 echo_request1500_1st_816 echo_request1500_1st_824
echo_request1500_1st_832 echo_request1500_1st_840 echo_request1500_1st_848
echo_request1500_1st_856 echo_request1500_1st_864 echo_request1500_1st_872
echo_request1500_1st_880 echo_request1500_1st_888 echo_request1500_1st_896
echo_request1500_1st_904 echo_request1500_1st_912 echo_request1500_1st_920
echo_request1500_1st_928 echo_request1500_1st_936 echo_request1500_1st_944
echo_request1500_1st_952 echo_request1500_1st_960 echo_request1500_1st_968
echo_request1500_1st_976 echo_request1500_1st_984 echo_request1500_1st_992
echo_request1500_1st_1000 echo_request1500_1st_1008 echo_request1500_1st_1016
echo_request1500_1st_1024 echo_request1500_1st_1032 echo_request1500_1st_1040
echo_request1500_1st_1048 echo_request1500_1st_1056 echo_request1500_1st_1064
echo_request1500_1st_1072 echo_request1500_1st_1080 echo_request1500_1st_1088
echo_request1500_1st_1096 echo_request1500_1st_1104 echo_request1500_1st_1112
echo_request1500_1st_1120 echo_request1500_1st_1128 echo_request1500_1st_1136
echo_request1500_1st_1144 echo_request1500_1st_1152 echo_request1500_1st_1160
echo_request1500_1st_1168 echo_request1500_1st_1176 echo_request1500_1st_1184
echo_request1500_1st_1192 echo_request1500_1st_1200 echo_request1500_1st_1208
echo_request1500_1st_1216 echo_request1500_1st_1224 echo_request1500_1st_1232
echo_request1500_1st_1240 echo_request1500_1st_1248 echo_request1500_1st_1256
echo_request1500_1st_1264 echo_request1500_1st_1272 echo_request1500_1st_1280
echo_request1500_1st_1288 echo_request1500_1st_1296 echo_request1500_1st_1304
echo_request1500_1st_1312 echo_request1500_1st_1320 echo_request1500_1st_1328
echo_request1500_1st_1336 echo_request1500_1st_1344 echo_request1500_1st_1352)
timeout:5 cntLimit:0 seektime:0
vRecv() return status=1

 Cannot receive Echo Request
NG
NUT send 4th Echo Request to Multicast Destination
09:59:14 Clear Captured Packets (Link0)
09:59:14  vRemote(ping6.rmt) ``/usr/local/v6eval//bin/rhel51//ping6.rmt -t
rhel51 -u root -p redhat -d cuad0 -o 1 size=1352 addr=FF1E::1:2 if=eth1 ''

Connected
prompt_user: ``login: '', prompt_password: ``Password: '', prompt_command:
``(\$|#) ''
rLogin: Wait for login prompt (0.2 sec)...
rLogin: Never got prompt; try again
rLogin: Wait for login prompt (50 sec)...

[root@ipv6test ~]# rLogin: Got command prompt
rLogin: Got command prompt
_rCommand: Try to get command prompt (0.2 sec.)
_rCommand: (\$|#) 
_rCommand: command prompt...
_rCommand: Try to get command prompt (15 sec.)
_rCommand: (\$|#) 

[root@ipv6test ~]# _rCommand: Do ``ping6 -n -c 1 -i 1 -s 1352 -p 00 -w 2 -I
eth1 FF1E::1:2'' command
ping6 -n -c 1 -i 1 -s 1352 -p 00 -w 2 -I eth1 FF1E::1:2
PATTErCommand: Try to get command prompt (0.2 sec)
RN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1352
data bytes
rCommand: Try to get command prompt (15 sec)


--- FF1E::1:2 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2000ms

[root@ipv6test ~]# 
[rrCommand: CmdOutput=``
PATTERN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1352
data bytes


--- FF1E::1:2 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2000ms

[root@ipv6test ~]''
oot@ipv6test ~]# echo $?
1
rCommand: exit status: 1
~
[EOT]

09:59:16  vRecv(Link0,u_ns_g2l_wo ns_l2l u_ns_g2l u_ns_l2l_wo ns_g2g
u_ns_l2g_wo u_ns_l2l ns_g2l u_ns_g2g u_ns_g2g_wo u_ns_l2g ns_l2g
echo_request_mc1400 echo_request1400_1st_8 echo_request1400_1st_16
echo_request1400_1st_24 echo_request1400_1st_32 echo_request1400_1st_40
echo_request1400_1st_48 echo_request1400_1st_56 echo_request1400_1st_64
echo_request1400_1st_72 echo_request1400_1st_80 echo_request1400_1st_88
echo_request1400_1st_96 echo_request1400_1st_104 echo_request1400_1st_112
echo_request1400_1st_120 echo_request1400_1st_128 echo_request1400_1st_136
echo_request1400_1st_144 echo_request1400_1st_152 echo_request1400_1st_160
echo_request1400_1st_168 echo_request1400_1st_176 echo_request1400_1st_184
echo_request1400_1st_192 echo_request1400_1st_200 echo_request1400_1st_208
echo_request1400_1st_216 echo_request1400_1st_224 echo_request1400_1st_232
echo_request1400_1st_240 echo_request1400_1st_248 echo_request1400_1st_256
echo_request1400_1st_264 echo_request1400_1st_272 echo_request1400_1st_280
echo_request1400_1st_288 echo_request1400_1st_296 echo_request1400_1st_304
echo_request1400_1st_312 echo_request1400_1st_320 echo_request1400_1st_328
echo_request1400_1st_336 echo_request1400_1st_344 echo_request1400_1st_352
echo_request1400_1st_360 echo_request1400_1st_368 echo_request1400_1st_376
echo_request1400_1st_384 echo_request1400_1st_392 echo_request1400_1st_400
echo_request1400_1st_408 echo_request1400_1st_416 echo_request1400_1st_424
echo_request1400_1st_432 echo_request1400_1st_440 echo_request1400_1st_448
echo_request1400_1st_456 echo_request1400_1st_464 echo_request1400_1st_472
echo_request1400_1st_480 echo_request1400_1st_488 echo_request1400_1st_496
echo_request1400_1st_504 echo_request1400_1st_512 echo_request1400_1st_520
echo_request1400_1st_528 echo_request1400_1st_536 echo_request1400_1st_544
echo_request1400_1st_552 echo_request1400_1st_560 echo_request1400_1st_568
echo_request1400_1st_576 echo_request1400_1st_584 echo_request1400_1st_592
echo_request1400_1st_600 echo_request1400_1st_608 echo_request1400_1st_616
echo_request1400_1st_624 echo_request1400_1st_632 echo_request1400_1st_640
echo_request1400_1st_648 echo_request1400_1st_656 echo_request1400_1st_664
echo_request1400_1st_672 echo_request1400_1st_680 echo_request1400_1st_688
echo_request1400_1st_696 echo_request1400_1st_704 echo_request1400_1st_712
echo_request1400_1st_720 echo_request1400_1st_728 echo_request1400_1st_736
echo_request1400_1st_744 echo_request1400_1st_752 echo_request1400_1st_760
echo_request1400_1st_768 echo_request1400_1st_776 echo_request1400_1st_784
echo_request1400_1st_792 echo_request1400_1st_800 echo_request1400_1st_808
echo_request1400_1st_816 echo_request1400_1st_824 echo_request1400_1st_832
echo_request1400_1st_840 echo_request1400_1st_848 echo_request1400_1st_856
echo_request1400_1st_864 echo_request1400_1st_872 echo_request1400_1st_880
echo_request1400_1st_888 echo_request1400_1st_896 echo_request1400_1st_904
echo_request1400_1st_912 echo_request1400_1st_920 echo_request1400_1st_928
echo_request1400_1st_936 echo_request1400_1st_944 echo_request1400_1st_952
echo_request1400_1st_960 echo_request1400_1st_968 echo_request1400_1st_976
echo_request1400_1st_984 echo_request1400_1st_992 echo_request1400_1st_1000
echo_request1400_1st_1008 echo_request1400_1st_1016 echo_request1400_1st_1024
echo_request1400_1st_1032 echo_request1400_1st_1040 echo_request1400_1st_1048
echo_request1400_1st_1056 echo_request1400_1st_1064 echo_request1400_1st_1072
echo_request1400_1st_1080 echo_request1400_1st_1088 echo_request1400_1st_1096
echo_request1400_1st_1104 echo_request1400_1st_1112 echo_request1400_1st_1120
echo_request1400_1st_1128 echo_request1400_1st_1136 echo_request1400_1st_1144
echo_request1400_1st_1152 echo_request1400_1st_1160 echo_request1400_1st_1168
echo_request1400_1st_1176 echo_request1400_1st_1184 echo_request1400_1st_1192
echo_request1400_1st_1200 echo_request1400_1st_1208 echo_request1400_1st_1216
echo_request1400_1st_1224 echo_request1400_1st_1232 echo_request1400_1st_1240
echo_request1400_1st_1248 echo_request1400_1st_1256 echo_request1400_1st_1264
echo_request1400_1st_1272 echo_request1400_1st_1280 echo_request1400_1st_1288
echo_request1400_1st_1296 echo_request1400_1st_1304 echo_request1400_1st_1312
echo_request1400_1st_1320 echo_request1400_1st_1328 echo_request1400_1st_1336
echo_request1400_1st_1344 echo_request1400_1st_1352) timeout:5 cntLimit:0
seektime:0
Recv multicast Echo Request (Packet size is 1400)

 OK
09:59:17 vSend(Link0,PktTooBig)
Send Packet Too Big message

 NUT send 5th Echo Request to Multicast Destination
09:59:17 Clear Captured Packets (Link0)
09:59:17  vRemote(ping6.rmt) ``/usr/local/v6eval//bin/rhel51//ping6.rmt -t
rhel51 -u root -p redhat -d cuad0 -o 1 size=1352 addr=FF1E::1:2 if=eth1 ''

Connected
prompt_user: ``login: '', prompt_password: ``Password: '', prompt_command:
``(\$|#) ''
rLogin: Wait for login prompt (0.2 sec)...
rLogin: Never got prompt; try again
rLogin: Wait for login prompt (50 sec)...

[root@ipv6test ~]# rLogin: Got command prompt
rLogin: Got command prompt
_rCommand: Try to get command prompt (0.2 sec.)
_rCommand: (\$|#) 
_rCommand: command prompt...
_rCommand: Try to get command prompt (15 sec.)
_rCommand: (\$|#) 

[root@ipv6test ~]# _rCommand: Do ``ping6 -n -c 1 -i 1 -s 1352 -p 00 -w 2 -I
eth1 FF1E::1:2'' command
ping6 -n -c 1 -i 1 -s 1352 -p 00 -w 2 -I eth1 FF1E::1:2
PATTErCommand: Try to get command prompt (0.2 sec)
RN: 0x00
PING FF1E::1:2(ff1rCommand: Try to get command prompt (15 sec)
e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1352 data bytes
>From 3ffe:501:ffff:100:21d:fff:fe0f:be4e icmp_seq=1 Packet too big: mtu=1300

--- FF1E::1:2 ping statistics ---
0 packets transmitted, 0 received, +1 errors


[root@ipv6test ~]# 
[roorCommand: CmdOutput=``
PATTERN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1352
data bytes
>From 3ffe:501:ffff:100:21d:fff:fe0f:be4e icmp_seq=1 Packet too big: mtu=1300

--- FF1E::1:2 ping statistics ---
0 packets transmitted, 0 received, +1 errors


[root@ipv6test ~]''
t@ipv6test ~]# echo $?
1rCommand: exit status: 1
~
[EOT]

09:59:18  vRecv(Link0,u_ns_g2l_wo ns_l2l u_ns_g2l u_ns_l2l_wo ns_g2g
u_ns_l2g_wo u_ns_l2l ns_g2l u_ns_g2g u_ns_g2g_wo u_ns_l2g ns_l2g
echo_request1400_1st_112 echo_request1400_1st_120 echo_request1400_1st_128
echo_request1400_1st_136 echo_request1400_1st_144 echo_request1400_1st_152
echo_request1400_1st_160 echo_request1400_1st_168 echo_request1400_1st_176
echo_request1400_1st_184 echo_request1400_1st_192 echo_request1400_1st_200
echo_request1400_1st_208 echo_request1400_1st_216 echo_request1400_1st_224
echo_request1400_1st_232 echo_request1400_1st_240 echo_request1400_1st_248
echo_request1400_1st_256 echo_request1400_1st_264 echo_request1400_1st_272
echo_request1400_1st_280 echo_request1400_1st_288 echo_request1400_1st_296
echo_request1400_1st_304 echo_request1400_1st_312 echo_request1400_1st_320
echo_request1400_1st_328 echo_request1400_1st_336 echo_request1400_1st_344
echo_request1400_1st_352 echo_request1400_1st_360 echo_request1400_1st_368
echo_request1400_1st_376 echo_request1400_1st_384 echo_request1400_1st_392
echo_request1400_1st_400 echo_request1400_1st_408 echo_request1400_1st_416
echo_request1400_1st_424 echo_request1400_1st_432 echo_request1400_1st_440
echo_request1400_1st_448 echo_request1400_1st_456 echo_request1400_1st_464
echo_request1400_1st_472 echo_request1400_1st_480 echo_request1400_1st_488
echo_request1400_1st_496 echo_request1400_1st_504 echo_request1400_1st_512
echo_request1400_1st_520 echo_request1400_1st_528 echo_request1400_1st_536
echo_request1400_1st_544 echo_request1400_1st_552 echo_request1400_1st_560
echo_request1400_1st_568 echo_request1400_1st_576 echo_request1400_1st_584
echo_request1400_1st_592 echo_request1400_1st_600 echo_request1400_1st_608
echo_request1400_1st_616 echo_request1400_1st_624 echo_request1400_1st_632
echo_request1400_1st_640 echo_request1400_1st_648 echo_request1400_1st_656
echo_request1400_1st_664 echo_request1400_1st_672 echo_request1400_1st_680
echo_request1400_1st_688 echo_request1400_1st_696 echo_request1400_1st_704
echo_request1400_1st_712 echo_request1400_1st_720 echo_request1400_1st_728
echo_request1400_1st_736 echo_request1400_1st_744 echo_request1400_1st_752
echo_request1400_1st_760 echo_request1400_1st_768 echo_request1400_1st_776
echo_request1400_1st_784 echo_request1400_1st_792 echo_request1400_1st_800
echo_request1400_1st_808 echo_request1400_1st_816 echo_request1400_1st_824
echo_request1400_1st_832 echo_request1400_1st_840 echo_request1400_1st_848
echo_request1400_1st_856 echo_request1400_1st_864 echo_request1400_1st_872
echo_request1400_1st_880 echo_request1400_1st_888 echo_request1400_1st_896
echo_request1400_1st_904 echo_request1400_1st_912 echo_request1400_1st_920
echo_request1400_1st_928 echo_request1400_1st_936 echo_request1400_1st_944
echo_request1400_1st_952 echo_request1400_1st_960 echo_request1400_1st_968
echo_request1400_1st_976 echo_request1400_1st_984 echo_request1400_1st_992
echo_request1400_1st_1000 echo_request1400_1st_1008 echo_request1400_1st_1016
echo_request1400_1st_1024 echo_request1400_1st_1032 echo_request1400_1st_1040
echo_request1400_1st_1048 echo_request1400_1st_1056 echo_request1400_1st_1064
echo_request1400_1st_1072 echo_request1400_1st_1080 echo_request1400_1st_1088
echo_request1400_1st_1096 echo_request1400_1st_1104 echo_request1400_1st_1112
echo_request1400_1st_1120 echo_request1400_1st_1128 echo_request1400_1st_1136
echo_request1400_1st_1144 echo_request1400_1st_1152 echo_request1400_1st_1160
echo_request1400_1st_1168 echo_request1400_1st_1176 echo_request1400_1st_1184
echo_request1400_1st_1192 echo_request1400_1st_1200 echo_request1400_1st_1208
echo_request1400_1st_1216 echo_request1400_1st_1224 echo_request1400_1st_1232
echo_request1400_1st_1240 echo_request1400_1st_1248) timeout:5 cntLimit:0
seektime:0
vRecv() return status=1

 Cannot receive Echo Request
NG
09:59:23 vSend(Link0,PktTooBig_others)
Send Packet Too Big message

 NUT send 6th Echo Request to Multicast Destination
09:59:23 Clear Captured Packets (Link0)
09:59:23  vRemote(ping6.rmt) ``/usr/local/v6eval//bin/rhel51//ping6.rmt -t
rhel51 -u root -p redhat -d cuad0 -o 1 size=1352 addr=FF1E::1:2 if=eth1 ''

Connected
prompt_user: ``login: '', prompt_password: ``Password: '', prompt_command:
``(\$|#) ''
rLogin: Wait for login prompt (0.2 sec)...
rLogin: Never got prompt; try again
rLogin: Wait for login prompt (50 sec)...

[root@ipv6test ~]# rLogin: Got command prompt
rLogin: Got command prompt
_rCommand: Try to get command prompt (0.2 sec.)
_rCommand: (\$|#) 
_rCommand: command prompt...
_rCommand: Try to get command prompt (15 sec.)
_rCommand: (\$|#) 

[root@ipv6test ~]# _rCommand: Do ``ping6 -n -c 1 -i 1 -s 1352 -p 00 -w 2 -I
eth1 FF1E::1:2'' command
ping6 -n -c 1 -i 1 -s 1352 -p 00 -w 2 -I eth1 FF1E::1:2
PATTErCommand: Try to get command prompt (0.2 sec)
RN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1352
data bytes
>From 3ffe:501:ffff:100:21d:fff:fe0f:be4e icmp_seq=1 Packet too big: mtu=1300

--- FF1E::1:2 ping statistics ---
0 packets transmitted, 0 received, +1 errors

[root@ipv6test ~]# rCommand: CmdOutput=``
PATTERN: 0x00
PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:21d:fff:fe0f:be4e eth1: 1352
data bytes
>From 3ffe:501:ffff:100:21d:fff:fe0f:be4e icmp_seq=1 Packet too big: mtu=1300

--- FF1E::1:2 ping statistics ---
0 packets transmitted, 0 received, +1 errors

[root@ipv6test ~]''
echo $?
1
[root@ipv6testrCommand: exit status: 1
~
[EOT]

09:59:24  vRecv(Link0,u_ns_g2l_wo ns_l2l u_ns_g2l u_ns_l2l_wo ns_g2g
u_ns_l2g_wo u_ns_l2l ns_g2l u_ns_g2g u_ns_g2g_wo u_ns_l2g ns_l2g
echo_request1400_1st_112 echo_request1400_1st_120 echo_request1400_1st_128
echo_request1400_1st_136 echo_request1400_1st_144 echo_request1400_1st_152
echo_request1400_1st_160 echo_request1400_1st_168 echo_request1400_1st_176
echo_request1400_1st_184 echo_request1400_1st_192 echo_request1400_1st_200
echo_request1400_1st_208 echo_request1400_1st_216 echo_request1400_1st_224
echo_request1400_1st_232 echo_request1400_1st_240 echo_request1400_1st_248
echo_request1400_1st_256 echo_request1400_1st_264 echo_request1400_1st_272
echo_request1400_1st_280 echo_request1400_1st_288 echo_request1400_1st_296
echo_request1400_1st_304 echo_request1400_1st_312 echo_request1400_1st_320
echo_request1400_1st_328 echo_request1400_1st_336 echo_request1400_1st_344
echo_request1400_1st_352 echo_request1400_1st_360 echo_request1400_1st_368
echo_request1400_1st_376 echo_request1400_1st_384 echo_request1400_1st_392
echo_request1400_1st_400 echo_request1400_1st_408 echo_request1400_1st_416
echo_request1400_1st_424 echo_request1400_1st_432 echo_request1400_1st_440
echo_request1400_1st_448 echo_request1400_1st_456 echo_request1400_1st_464
echo_request1400_1st_472 echo_request1400_1st_480 echo_request1400_1st_488
echo_request1400_1st_496 echo_request1400_1st_504 echo_request1400_1st_512
echo_request1400_1st_520 echo_request1400_1st_528 echo_request1400_1st_536
echo_request1400_1st_544 echo_request1400_1st_552 echo_request1400_1st_560
echo_request1400_1st_568 echo_request1400_1st_576 echo_request1400_1st_584
echo_request1400_1st_592 echo_request1400_1st_600 echo_request1400_1st_608
echo_request1400_1st_616 echo_request1400_1st_624 echo_request1400_1st_632
echo_request1400_1st_640 echo_request1400_1st_648 echo_request1400_1st_656
echo_request1400_1st_664 echo_request1400_1st_672 echo_request1400_1st_680
echo_request1400_1st_688 echo_request1400_1st_696 echo_request1400_1st_704
echo_request1400_1st_712 echo_request1400_1st_720 echo_request1400_1st_728
echo_request1400_1st_736 echo_request1400_1st_744 echo_request1400_1st_752
echo_request1400_1st_760 echo_request1400_1st_768 echo_request1400_1st_776
echo_request1400_1st_784 echo_request1400_1st_792 echo_request1400_1st_800
echo_request1400_1st_808 echo_request1400_1st_816 echo_request1400_1st_824
echo_request1400_1st_832 echo_request1400_1st_840 echo_request1400_1st_848
echo_request1400_1st_856 echo_request1400_1st_864 echo_request1400_1st_872
echo_request1400_1st_880 echo_request1400_1st_888 echo_request1400_1st_896
echo_request1400_1st_904 echo_request1400_1st_912 echo_request1400_1st_920
echo_request1400_1st_928 echo_request1400_1st_936 echo_request1400_1st_944
echo_request1400_1st_952 echo_request1400_1st_960 echo_request1400_1st_968
echo_request1400_1st_976 echo_request1400_1st_984 echo_request1400_1st_992
echo_request1400_1st_1000 echo_request1400_1st_1008 echo_request1400_1st_1016
echo_request1400_1st_1024 echo_request1400_1st_1032 echo_request1400_1st_1040
echo_request1400_1st_1048 echo_request1400_1st_1056 echo_request1400_1st_1064
echo_request1400_1st_1072 echo_request1400_1st_1080 echo_request1400_1st_1088
echo_request1400_1st_1096 echo_request1400_1st_1104 echo_request1400_1st_1112
echo_request1400_1st_1120 echo_request1400_1st_1128 echo_request1400_1st_1136
echo_request1400_1st_1144 echo_request1400_1st_1152 echo_request1400_1st_1160
echo_request1400_1st_1168 echo_request1400_1st_1176 echo_request1400_1st_1184
echo_request1400_1st_1192 echo_request1400_1st_1200 echo_request1400_1st_1208
echo_request1400_1st_1216 echo_request1400_1st_1224 echo_request1400_1st_1232
echo_request1400_1st_1240 echo_request1400_1st_1248) timeout:5 cntLimit:0
seektime:0
vRecv() return status=1

 Cannot receive Echo Request
NG





failed tcpdump info: 
reading from file 151.html.Link0.dump, link-type EN10MB (Ethernet)
00:42:18.381723 IP6 fe80::200:ff:fe00:100 > fe80::21d:fff:fe0f:be4e: ICMP6,
echo request, seq 0, length 16
00:42:18.382200 IP6 fe80::21d:fff:fe0f:be4e > ff02::1:ff00:100: ICMP6, neighbor
solicitation, who has fe80::200:ff:fe00:100, length 32
00:42:18.434130 IP6 fe80::200:ff:fe00:100 > fe80::21d:fff:fe0f:be4e: ICMP6,
neighbor advertisement, tgt is fe80::200:ff:fe00:100, length 32
00:42:18.434261 IP6 fe80::21d:fff:fe0f:be4e > fe80::200:ff:fe00:100: ICMP6,
echo reply, seq 0, length 16
00:42:18.485959 IP6 fe80::200:ff:fe00:100 > ff02::1: ICMP6, router
advertisement, length 64
00:42:18.541190 IP6 :: > ff02::1:ff0f:be4e: ICMP6, neighbor solicitation, who
has 3ffe:501:ffff:100:21d:fff:fe0f:be4e, length 24
00:42:23.568201 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:21d:fff:fe0f:be4e: ICMP6, echo request, seq 0, length 16
00:42:23.569298 IP6 3ffe:501:ffff:100:21d:fff:fe0f:be4e > ff02::1:ff00:100:
ICMP6, neighbor solicitation, who has 3ffe:501:ffff:100:200:ff:fe00:100, length
32
00:42:23.620369 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:21d:fff:fe0f:be4e: ICMP6, neighbor advertisement, tgt is
3ffe:501:ffff:100:200:ff:fe00:100, length 32
00:42:23.620447 IP6 3ffe:501:ffff:100:21d:fff:fe0f:be4e >
3ffe:501:ffff:100:200:ff:fe00:100: ICMP6, echo reply, seq 0, length 16
00:42:25.398359 IP6 3ffe:501:ffff:100:21d:fff:fe0f:be4e > ff1e::1:2: ICMP6,
echo request, seq 1, length 1460
00:42:26.397533 IP6 3ffe:501:ffff:100:21d:fff:fe0f:be4e > ff1e::1:2: ICMP6,
echo request, seq 2, length 1460
00:42:27.397558 IP6 3ffe:501:ffff:100:21d:fff:fe0f:be4e > ff1e::1:2: ICMP6,
echo request, seq 3, length 1460
00:42:27.878750 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:21d:fff:fe0f:be4e: ICMP6, packet too big, mtu 1450, length
1240
00:42:34.037953 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:21d:fff:fe0f:be4e: ICMP6, packet too big, mtu 1400, length
1240
00:42:41.131260 IP6 3ffe:501:ffff:100:21d:fff:fe0f:be4e > ff1e::1:2: ICMP6,
echo request, seq 1, length 1360
00:42:42.130832 IP6 3ffe:501:ffff:100:21d:fff:fe0f:be4e > ff1e::1:2: ICMP6,
echo request, seq 2, length 1360
00:42:43.130845 IP6 3ffe:501:ffff:100:21d:fff:fe0f:be4e > ff1e::1:2: ICMP6,
echo request, seq 3, length 1360
00:42:43.551766 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:21d:fff:fe0f:be4e: ICMP6, packet too big, mtu 1300, length
1240
00:42:49.735867 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:21d:fff:fe0f:be4e: ICMP6, packet too big, mtu 1350, length
1240
00:43:55.485037 IP6 :: > ff02::16: HBH ICMP6, multicast listener report v2, 1
group record(s), length 28
00:43:55.847954 IP6 :: > ff02::16: HBH ICMP6, multicast listener report v2, 1
group record(s), length 28
00:43:56.477020 IP6 :: > ff02::1:ff0f:be4e: ICMP6, neighbor solicitation, who
has fe80::21d:fff:fe0f:be4e, length 24
00:43:57.477130 IP6 fe80::21d:fff:fe0f:be4e > ff02::2: ICMP6, router
solicitation, length 16



pass tcpdump info:
reading from file 15.html.Link0.dump, link-type EN10MB (Ethernet)
18:21:43.902212 IP6 fe80::200:ff:fe00:100 > fe80::20a:ebff:fe85:9e56: ICMP6,
echo request, seq 0, length 16
18:21:43.902734 IP6 fe80::20a:ebff:fe85:9e56 > ff02::1:ff00:100: ICMP6,
neighbor solicitation, who has fe80::200:ff:fe00:100, length 32
18:21:43.947241 IP6 fe80::200:ff:fe00:100 > fe80::20a:ebff:fe85:9e56: ICMP6,
neighbor advertisement, tgt is fe80::200:ff:fe00:100, length 32
18:21:43.947297 IP6 fe80::20a:ebff:fe85:9e56 > fe80::200:ff:fe00:100: ICMP6,
echo reply, seq 0, length 16
18:21:43.986679 IP6 fe80::200:ff:fe00:100 > ff02::1: ICMP6, router
advertisement, length 64
18:21:44.132013 IP6 fe80::20a:ebff:fe85:9e56.mdns > ff02::fb.mdns:  0*- [0q]
7/0/0 (Cache flush) TXT "org.freedesktop.Avahi.cookie=3535550568", (Cache
flush) AAAA fe80::20a:ebff:fe85:9e56, (Cache flush) PTR ipv6test.local., (Cache
flush) HINFO, (Cache flush) SRV ipv6test.local.:9 0 0, (Cache flush) TXT
"org.freedesktop.Avahi.cookie=3535550568", (Cache flush) SRV ipv6test.local.:22
0 0 (395)
18:21:44.653696 IP6 :: > ff02::1:ff85:9e56: ICMP6, neighbor solicitation, who
has 3ffe:501:ffff:100:20a:ebff:fe85:9e56, length 24
18:21:45.598851 IP6 fe80::20a:ebff:fe85:9e56.mdns > ff02::fb.mdns:  0*- [0q]
9/0/0 PTR _sftp-ssh._tcp.local., PTR ipv6test
[00:0a:eb:85:9e:56]._workstation._tcp.local., (Cache flush) TXT
"org.freedesktop.Avahi.cookie=3535550568", (Cache flush) SRV ipv6test.local.:9
0 0, (Cache flush) AAAA fe80::20a:ebff:fe85:9e56, PTR _workstation._tcp.local.,
PTR SFTP File Transfer on ipv6test._sftp-ssh._tcp.local., (Cache flush) TXT
"org.freedesktop.Avahi.cookie=3535550568", (Cache flush) SRV ipv6test.local.:22
0 0 (365)
18:21:45.653951 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0*- [0q] 2/0/0 (Cache flush) PTR ipv6test.local., (Cache flush) AAAA
fe80::20a:ebff:fe85:9e56 (140)
18:21:45.655683 IP6 fe80::20a:ebff:fe85:9e56 > ff02::16: HBH ICMP6, multicast
listener report v2, 1 group record(s), length 28
18:21:45.847723 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0 [2q] [2n] ANY?
6.5.e.9.5.8.e.f.f.f.b.e.a.0.2.0.0.0.1.0.f.f.f.f.1.0.5.0.e.f.f.3.ip6.arpa. ANY?
ipv6test.local. (152)
18:21:45.847853 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0*- [0q] 1/0/0 (Cache flush) HINFO (49)
18:21:46.098715 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0 [2q] [2n] ANY?
6.5.e.9.5.8.e.f.f.f.b.e.a.0.2.0.0.0.1.0.f.f.f.f.1.0.5.0.e.f.f.3.ip6.arpa. ANY?
ipv6test.local. (152)
18:21:46.274795 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0*- [0q] 4/0/0 (Cache flush) TXT "org.freedesktop.Avahi.cookie=3535550568",
(Cache flush) SRV ipv6test.local.:9 0 0, (Cache flush) TXT
"org.freedesktop.Avahi.cookie=3535550568", (Cache flush) SRV ipv6test.local.:22
0 0 (258)
18:21:46.348706 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0 [2q] [2n] ANY?
6.5.e.9.5.8.e.f.f.f.b.e.a.0.2.0.0.0.1.0.f.f.f.f.1.0.5.0.e.f.f.3.ip6.arpa. ANY?
ipv6test.local. (152)
18:21:46.348832 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0*- [0q] 1/0/0 (Cache flush) HINFO (49)
18:21:46.549739 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0*- [0q] 2/0/0 (Cache flush) PTR ipv6test.local., (Cache flush) AAAA
3ffe:501:ffff:100:20a:ebff:fe85:9e56 (140)
18:21:47.692680 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0*- [0q] 2/0/0 (Cache flush) PTR ipv6test.local., (Cache flush) AAAA
3ffe:501:ffff:100:20a:ebff:fe85:9e56 (140)
18:21:49.686249 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:20a:ebff:fe85:9e56: ICMP6, echo request, seq 0, length 16
18:21:49.686483 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff02::1:ff00:100:
ICMP6, neighbor solicitation, who has 3ffe:501:ffff:100:200:ff:fe00:100, length
32
18:21:49.741762 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:20a:ebff:fe85:9e56: ICMP6, neighbor advertisement, tgt is
3ffe:501:ffff:100:200:ff:fe00:100, length 32
18:21:49.741816 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 >
3ffe:501:ffff:100:200:ff:fe00:100: ICMP6, echo reply, seq 0, length 16
18:21:49.836595 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0*- [0q] 2/0/0 (Cache flush) PTR ipv6test.local., (Cache flush) AAAA
3ffe:501:ffff:100:20a:ebff:fe85:9e56 (140)
18:21:51.094278 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: ICMP6,
echo request, seq 0, length 1460
18:21:52.093661 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: ICMP6,
echo request, seq 1, length 1460
18:21:53.094618 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: ICMP6,
echo request, seq 2, length 1460
18:21:53.448470 IP6 fe80::20a:ebff:fe85:9e56 > ff02::16: HBH ICMP6, multicast
listener report v2, 1 group record(s), length 28
18:21:53.511502 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:20a:ebff:fe85:9e56: ICMP6, packet too big, mtu 1450, length
1240
18:21:54.237694 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1400) ICMP6, echo request, seq 0, length 1400
18:21:54.237709 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1400|60)
18:21:55.238522 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1400) ICMP6, echo request, seq 1, length 1400
18:21:55.238534 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1400|60)
18:21:56.238482 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1400) ICMP6, echo request, seq 2, length 1400
18:21:56.238494 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1400|60)
18:21:56.790600 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:20a:ebff:fe85:9e56: ICMP6, packet too big, mtu 1400, length
1240
18:21:57.514546 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1352) ICMP6, echo request, seq 0, length 1352
18:21:57.514566 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1352|108)
18:21:58.514381 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1352) ICMP6, echo request, seq 1, length 1352
18:21:58.514394 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1352|108)
18:21:59.514333 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1352) ICMP6, echo request, seq 2, length 1352
18:21:59.514343 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1352|108)
18:22:00.707357 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: ICMP6,
echo request, seq 0, length 1360
18:22:01.707247 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: ICMP6,
echo request, seq 1, length 1360
18:22:02.707196 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: ICMP6,
echo request, seq 2, length 1360
18:22:03.079178 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:20a:ebff:fe85:9e56: ICMP6, packet too big, mtu 1300, length
1240
18:22:03.776219 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1248) ICMP6, echo request, seq 0, length 1248
18:22:03.776233 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1248|112)
18:22:04.776102 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1248) ICMP6, echo request, seq 1, length 1248
18:22:04.776114 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1248|112)
18:22:05.776055 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1248) ICMP6, echo request, seq 2, length 1248
18:22:05.776066 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1248|112)
18:22:06.246141 IP6 3ffe:501:ffff:100:200:ff:fe00:100 >
3ffe:501:ffff:100:20a:ebff:fe85:9e56: ICMP6, packet too big, mtu 1350, length
1240
18:22:06.965159 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1248) ICMP6, echo request, seq 0, length 1248
18:22:06.965174 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1248|112)
18:22:07.964967 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1248) ICMP6, echo request, seq 1, length 1248
18:22:07.964980 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1248|112)
18:22:08.964922 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(0|1248) ICMP6, echo request, seq 2, length 1248
18:22:08.964933 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56 > ff1e::1:2: frag
(1248|112)
18:22:11.439505 IP6 3ffe:501:ffff:100:20a:ebff:fe85:9e56.mdns > ff02::fb.mdns: 
0*- [0q] 10/0/0 (Cache flush) HINFO, PTR ipv6test
[00:0a:eb:85:9e:56]._workstation._tcp.local., (Cache flush) SRV
ipv6test.local.:9 0 0, (Cache flush) TXT
"org.freedesktop.Avahi.cookie=3535550568", (Cache flush) AAAA
3ffe:501:ffff:100:20a:ebff:fe85:9e56, (Cache flush) PTR ipv6test.local., PTR
SFTP File Transfer on ipv6test._sftp-ssh._tcp.local., (Cache flush) SRV
ipv6test.local.:22 0 0, (Cache flush) TXT
"org.freedesktop.Avahi.cookie=3535550568", PTR _sftp-ssh._tcp.local. (460)
18:22:11.442472 IP6 fe80::20a:ebff:fe85:9e56 > ff02::16: HBH ICMP6, multicast
listener report v2, 1 group record(s), length 28
18:22:16.905614 IP6 fe80::20a:ebff:fe85:9e56 > ff02::16: HBH ICMP6, multicast
listener report v2, 1 group record(s), length 28
18:24:32.544009 IP6 :: > ff02::16: HBH ICMP6, multicast listener report v2, 1
group record(s), length 28
18:24:32.611958 IP6 :: > ff02::1:ff85:9e56: ICMP6, neighbor solicitation, who
has fe80::20a:ebff:fe85:9e56, length 24
18:24:33.611454 IP6 fe80::20a:ebff:fe85:9e56 > ff02::2: ICMP6, router
solicitation, length 16
18:24:33.613433 IP6 fe80::20a:ebff:fe85:9e56 > ff02::16: HBH ICMP6, multicast
listener report v2, 2 group record(s), length 48
18:24:33.874604 IP6 fe80::20a:ebff:fe85:9e56.mdns > ff02::fb.mdns:  0 [4q] [7n]
ANY? SFTP File Transfer on ipv6test._sftp-ssh._tcp.local. ANY? ipv6test.local.
ANY? 6.5.e.9.5.8.e.f.f.f.b.e.a.0.2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa.
ANY? ipv6test [00:0a:eb:85:9e:56]._workstation._tcp.local. (419)
18:24:33.928510 IP6 fe80::20a:ebff:fe85:9e56.mdns > ff02::fb.mdns:  0*- [0q]
4/0/0 PTR _sftp-ssh._tcp.local., PTR ipv6test
[00:0a:eb:85:9e:56]._workstation._tcp.local., PTR _workstation._tcp.local., PTR
SFTP File Transfer on ipv6test._sftp-ssh._tcp.local. (184)
18:24:34.125552 IP6 fe80::20a:ebff:fe85:9e56.mdns > ff02::fb.mdns:  0 [4q] [7n]
ANY? SFTP File Transfer on ipv6test._sftp-ssh._tcp.local. ANY? ipv6test.local.
ANY? 6.5.e.9.5.8.e.f.f.f.b.e.a.0.2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa.
ANY? ipv6test [00:0a:eb:85:9e:56]._workstation._tcp.local. (419)
18:24:34.377645 IP6 fe80::20a:ebff:fe85:9e56.mdns > ff02::fb.mdns:  0 [4q] [7n]
ANY? SFTP File Transfer on ipv6test._sftp-ssh._tcp.local. ANY? ipv6test.local.
ANY? 6.5.e.9.5.8.e.f.f.f.b.e.a.0.2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa.
ANY? ipv6test [00:0a:eb:85:9e:56]._workstation._tcp.local. (419)
18:24:34.576695 IP6 fe80::20a:ebff:fe85:9e56.mdns > ff02::fb.mdns:  0*- [0q]
7/0/0 (Cache flush) TXT "org.freedesktop.Avahi.cookie=1339299084", (Cache
flush) AAAA fe80::20a:ebff:fe85:9e56, (Cache flush) PTR ipv6test.local., (Cache
flush) HINFO, (Cache flush) SRV ipv6test.local.:9 0 0, (Cache flush) TXT
"org.freedesktop.Avahi.cookie=1339299084", (Cache flush) SRV ipv6test.local.:22
0 0 (395)

-- 
Configure bugmail: https://bugzilla.redhat.com/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are on the CC list for the bug.
You are the assignee for the bug.

--fUYQa+Pmc3FrFX/N--
