From: Mark Huth <mhuth@mvista.com>
Subject: Fix to have sysfs track rename of network devices
Date: Thu, 14 Aug 2003 12:03:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3BDCF3.5050708@mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070309000706020401080306"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070309000706020401080306
Content-Type: multipart/alternative;
 boundary="------------090404000602010207080904"


--------------090404000602010207080904
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Description:

When an Ethernet interface is renamed in the kernel via the ioctl SIOCSIFNAME, the sysfs directories /sys/class/net/ethX are not changed to the new name.  This patch ensures sysfs is updated to the new name  specified by the rename ioctl.

Thanks,
Mark Huth



--------------090404000602010207080904
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">
  <title></title>
</head>
<body>
<div class="moz-text-plain" wrap="true" graphical-quote="true"
 style="font-size: 16px;" lang="x-western">
<pre wrap="">Description:

When an Ethernet interface is renamed in the kernel via the ioctl SIOCSIFNAME, the sysfs directories /sys/class/net/ethX are not changed to the new name.  This patch ensures sysfs is updated to the new name  specified by the rename ioctl.

Thanks,
Mark Huth

</pre>
</div>
</body>
</html>

--------------090404000602010207080904--

--------------070309000706020401080306
Content-Type: application/octet-stream;
 name="2.6.0-test3-fixifrename.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="2.6.0-test3-fixifrename.patch"

ZGlmZiAtdU5yIGxpbnV4LTIuNi4wLXRlc3QzL25ldC9jb3JlL2Rldi5jIGxpbnV4LTIuNi4w
LXRlc3QzLWZpeGlmcmVuYW1lL25ldC9jb3JlL2Rldi5jDQotLS0gbGludXgtMi42LjAtdGVz
dDMvbmV0L2NvcmUvZGV2LmMJMjAwMy0wOC0wOCAyMTozNjo1MC4wMDAwMDAwMDAgLTA3MDAN
CisrKyBsaW51eC0yLjYuMC10ZXN0My1maXhpZnJlbmFtZS9uZXQvY29yZS9kZXYuYwkyMDAz
LTA4LTEzIDE2OjExOjAzLjAwMDAwMDAwMCAtMDcwMA0KQEAgLTIzNDUsOSArMjM0NSwxMSBA
QA0KIAkJCQlyZXR1cm4gLUVCVVNZOw0KIAkJCWlmIChfX2Rldl9nZXRfYnlfbmFtZShpZnIt
Pmlmcl9uZXduYW1lKSkNCiAJCQkJcmV0dXJuIC1FRVhJU1Q7DQorCQkJbmV0ZGV2X3VucmVn
aXN0ZXJfc3lzZnMoZGV2KTsNCiAJCQltZW1jcHkoZGV2LT5uYW1lLCBpZnItPmlmcl9uZXdu
YW1lLCBJRk5BTVNJWik7DQogCQkJZGV2LT5uYW1lW0lGTkFNU0laIC0gMV0gPSAwOw0KIAkJ
CXN0cmxjcHkoZGV2LT5jbGFzc19kZXYuY2xhc3NfaWQsIGRldi0+bmFtZSwgQlVTX0lEX1NJ
WkUpOw0KKwkJCW5ldGRldl9yZWdpc3Rlcl9zeXNmcyhkZXYpOw0KIAkJCW5vdGlmaWVyX2Nh
bGxfY2hhaW4oJm5ldGRldl9jaGFpbiwNCiAJCQkJCSAgICBORVRERVZfQ0hBTkdFTkFNRSwg
ZGV2KTsNCiAJCQlyZXR1cm4gMDsNCg==
--------------070309000706020401080306--
