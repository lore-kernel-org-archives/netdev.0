From: "David S. Miller" <davem@redhat.com>
Subject: Fw: hfsc and huge set of rules
Date: Thu, 29 Jul 2004 21:18:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729211844.61e8d328.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Thu__29_Jul_2004_21_18_44_-0700_NIkkprkv1fCQq2fm"
Cc: hadi@cyberus.ca, devik@cdi.cz, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kaber@trash.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Thu__29_Jul_2004_21_18_44_-0700_NIkkprkv1fCQq2fm
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


Looks like qdisc destruction has some expensive algorithms.
Any quick ideas about the root culprit at least in the hfsc
case?  He says htb does it too.

Begin forwarded message:

Date: Tue, 27 Jul 2004 11:47:02 +0200
From: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
To: linux-kernel@vger.kernel.org
Subject: hfsc and huge set of rules


Hello,

I'am running hfsc qdisc with huge set of rules loaded.

root@hades:/home/system/scr/etc/hfsc_rebuild# cat tc.batch | grep hfsc | wc -l
  27884


Always when I delete the root qdisc (qdisc del dev eth0 root)
the machine stop responding for about 5-6 seconds. As I think it's due the
hfsc_destory_qdisc is executed in main kernel thread. Similar problem is
present also in htb scheduler.

Is there any quick solution to solve this problem ?

-- 
Tomasz Paszkowski
Administrator
Miejskie Sieci Informatyczne e-wro
http://www.e-wro.pl


--Multipart=_Thu__29_Jul_2004_21_18_44_-0700_NIkkprkv1fCQq2fm
Content-Type: application/pgp-signature;
 name="00000000.mimetmp"
Content-Disposition: attachment;
 filename="00000000.mimetmp"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuMi4xIChHTlUv
TGludXgpCgppRDhEQlFGQkJpU1djTlhPTDk4WGV5c1JBaVE1QUp3S20zTVdITkhsVUtEaXJ2QkUv
TS9zZVN5ekpnQ2ZlVUNKCmNZR0k0L3FwSkZZcEFNQTBUQTFybHhnPQo9QWMrdwotLS0tLUVORCBQ
R1AgU0lHTkFUVVJFLS0tLS0KCg==

--Multipart=_Thu__29_Jul_2004_21_18_44_-0700_NIkkprkv1fCQq2fm--
