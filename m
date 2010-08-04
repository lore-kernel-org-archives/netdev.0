From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 16483] New: linux 2.6.30 kernel update to 2.6.34 appear
 networking's bug
Date: Wed, 4 Aug 2010 09:59:32 -0700
Message-ID: <20100804095932.19a31d41@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60544 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186Ab0HDQ7e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 12:59:34 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 201A718290AD
	for <netdev@vger.kernel.org>; Wed,  4 Aug 2010 09:55:30 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QLnjvcfF4guw for <netdev@vger.kernel.org>;
	Wed,  4 Aug 2010 09:55:29 -0700 (PDT)
Received: from nehalam (pool-74-107-135-205.ptldor.fios.verizon.net [74.107.135.205])
	by mail.vyatta.com (Postfix) with ESMTPSA id 35EFB182901C
	for <netdev@vger.kernel.org>; Wed,  4 Aug 2010 09:55:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cryptic bug report, more info in bugzilla comments.

Begin forwarded message:

Date: Fri, 30 Jul 2010 07:57:46 GMT
=46rom: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 16483] New: linux 2.6.30 kernel update to 2.6.34 appear n=
etworking's bug


https://bugzilla.kernel.org/show_bug.cgi?id=3D16483

           Summary: linux 2.6.30 kernel update to 2.6.34 appear
                    networking's bug
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.34
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: lys0212@qq.com
        Regression: No


linux 2.6.30 kernel update to 2.6.34 appear networking's bug
my server machine install linux 5.5 and 2.6.30 kernel,it has two NIC:et=
h0 and
eth1.
eth0 and eth1 have different's ip and gateway .all configuration is nor=
mal.i
can ping both the eth0 and eth1 .but,when i update to kernel 2.6.34,i c=
an't
ping both the eth0 and eth1,only can ping  the eth0 when the default gw=
 is
eth0's gw.when i change the default gw to eth1's gw ,i can ping the eth=
1
only,eth0 can't ping .Very strange!
when i use the kernel 2.6.30 to boot the system ,all is normal ,i can p=
ing both
eth0 and eth1 .but when i use the kernel 2.6.34,one of the ethX is norm=
al only.
   the follows show how i update 2.6.30 to 2.6.34:
mv linux-2.6.34.tar.bz2  /usr/src
cd /usr/src/
tar -xvf linux-2.6.34.tar.bz2
ln -s /usr/src/linux-2.6.34  /usr/src/linux=20

cd linux
make menuconfig=20
#cp the boot initilization configuration to  /usr/src/linux/.config
cp /boot/config-2.6.18-194.el5 /usr/src/linux/.config
make menuconfig

# choose ip range      network -> Netfilter > Core NetFilter >iprange
select:
=EF=BC=881=EF=BC=89General setup ---> Prompt for development and/or inc=
omplete code/drivers=E3=80=82=20
=EF=BC=882=EF=BC=89 Networking ---> Networking options ---> Network pac=
ket filtering framework
(Netfilter) ---> Core Netfilter Configuration ---> =E5=92=8C IP: Netfil=
ter
Configuration ---> (select all)
vi .config
CONFIG_NF_CONNTRACK_IPV4=3Dy
CONFIG_SYSFS_DEPRECATED_V2=3Dy

--=20
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=3Demai=
l
------- You are receiving this mail because: -------
You are the assignee for the bug.


--=20
