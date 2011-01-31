From: Julien =?ISO-8859-1?B?QXVi6Q==?= <jul.aube@gmail.com>
Subject: [PATCH] IPv6 configurable default value for the privacy extension
 flag
Date: Mon, 31 Jan 2011 16:49:45 +0100
Message-ID: <20110131164945.3370cbcd@baileys.at.home>
Reply-To: j.aube@laposte.net
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/reQop1X/jU4Zx9Z/avA4491"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40345 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab1AaPwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 10:52:18 -0500
Received: by bwz15 with SMTP id 15so5368657bwz.19
        for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 07:52:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/reQop1X/jU4Zx9Z/avA4491
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: base64
Content-Disposition: inline

LS0tLS1CRUdJTiBQR1AgU0lHTkVEIE1FU1NBR0UtLS0tLQ0KSGFzaDogU0hBMQ0KDQpIZWxsbywN
Cg0KVGhlIGZvbGxvd2luZyBwYXRjaCBpcyBhIHByb3Bvc2FsIG9ubHkuDQoNClRoZSBnb2FsIGlz
IHRvICJwcmVzZXQiIHRoZSBkZWZhdWx0IHZhbHVlIG9mIHRoZSBmbGFnIHVzZV90ZW1wYWRkciBm
b3IgdGhlIGFsbC8gYW5kIGNvbmYvIGNvbmZpZ3VyYXRpb24gc3BhY2UuIA0KDQpUaGUgcmVhc29u
IHdoeSBJIGRpZCB0aGlzIHBhdGNoIGlzIGJlY2F1c2UgZnJlcXVlbnRseSwgSSBoYXZlIGEgcmFj
ZSBiZXR3ZWVuIHRoZSBpbnRlcmZhY2UgY29taW5nIHVwIGFuZCB0aGUgZmxhZzoNClVzdWFsbHks
IGp1c3Qgc2V0dGluZyB0aGUgZmxhZyB0byAyIGluIC9ldGMvc3lzY3RsLmNvbmYgaXMgbm90IGVu
b3VnaCA6IEF0IHRoaXMgbW9tZW50IG9mIHRoZSBib290LCBldmVuIGlmIHRoZSBpbnRlcmZhY2Ug
aGFzIG5vDQpJUHY0IHlldCwgaXQgbWF5IGhhdmUgYWxyZWFkeSBhbiBJUHY2LCBnb3QgYnkgUkEu
DQoNCkJ1dCBpZiBhdCB0aGlzIHRpbWUgdGhlIGZsYWcgaXMgMCwgdGhlbiB0aGUgaW50ZXJmYWNl
IHdpbGwga2VlcCB0aGUgYWRkcmVzcyBkZXJpdmVkIGZyb20gdGhlIE1hYyBBZGRyZXNzLiBGb3Jl
dmVyLg0KVGhlIG9ubHkgc29sdXRpb24gaXMgdG8gYnJpbmcgZG93biB0aGUgaW50ZXJmYWNlIGFu
ZCBicmluZyBpdCB1cCBhZ2FpbiwgbWFudWFsbHkuIA0KDQpUaGF0J3Mgd2h5IEkgY3JlYXRlZCB0
aGlzIHBhdGNoLg0KSSdtIG5vdCBzdXJlIGlmIHRoaXMgaXMgdGhlIGdvb2QgaW1wbGVtZW50YXRp
b24gdG8gZG8sIG9yIGV2ZW4gaWYgaXQgaXMgdGhlIHJpZ2h0IHdheSB0byBzY3JhdGNoIG15IG93
biBpdGNoLCBidXQgaXQgDQpkb2VzIHdvcmsgbmV2ZXJ0aGVsZXNzLg0KSSBrbm93IHRoZSBQcml2
YWN5IEV4dGVuc2lvbiBpcyBzb21ld2hhdCBjb250cm92ZXJzaWFsLCBidXQgYW55d2F5LCBJIGRv
IHByZWZlciB0byBoYXZlIGl0IG9uLCBmb3IgbXlzZWxmLg0KDQpJJ20gd2lsbGluZyB0byB0byBs
aXN0ZW4gdG8gYW55IGNvbW1lbnRzIGFuZCBtb2RpZnkgbXkgcGF0Y2ggYWNjb3JkaW5nbHkuIA0K
DQpUaGFua3MsDQoNCkp1bGllbiBBdWLpIC0gai5hdWJlQGxhcG9zdGUubmV0DQoNCi0gLS0gDQpQ
ZW9wbGUgaW4gdGhlIGVtYmVkZGVkIHNwYWNlIGRvbid0IGRvIHByb3RvdHlwZXMuIFRoZXkgaGFj
ayBzb21ldGhpbmcgdW50aWwgaXQgd29ya3MsIHRoZW4gaXQncyBkb25lLg0KLSAtLS0gDQpsZSBy
ZXNlYXUgcGFyIHRlcnJlLCBjJ2VzdCBkJ2xhIGZhdXRlIGEgcmVuYXRlcg0KbGUgbmV6IGRhbnMg
bGUgcnVpc3NlYXUsIGMnZXN0IGxhIGZhdXRlIGEgY2lzY28NCi0tLS0tQkVHSU4gUEdQIFNJR05B
VFVSRS0tLS0tDQpWZXJzaW9uOiBHbnVQRyB2MS40LjEwIChHTlUvTGludXgpDQoNCmlFWUVBUkVD
QUFZRkFrMUcyaGtBQ2drUUhpejFtRDJzVThpckxBQ2VNOVpCaVErV1NqMmRWSW15b3JSdXdFVlkN
CjlVd0FvSlZwM3czVnArOUhSZTZCUlc1OXkvS3JuRHNyDQo9emxrMw0KLS0tLS1FTkQgUEdQIFNJ
R05BVFVSRS0tLS0tDQo=

--MP_/reQop1X/jU4Zx9Z/avA4491
Content-Type: text/x-patch
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=ipv6_privacy_default_setting.patch

commit 59dd205f4d8f281cd39429bbb6a9f158be8adcd1
Author: Julien Aube <j.aube@laposte.net>
Date:   Mon Jan 24 11:15:49 2011 +0100

    [IPv6]: Add a kernel parameter to preset the default value of the use_t=
empaddr flag.
   =20
    This patch add the kernel parameter '--ipv6.privacy_default=3D[0|1|2]' =
, which preset the
    value of the flags /proc/sys/net/ipv6/conf/all/use_tempaddr and
    /proc/sys/net/ipv6/conf/conf/use_tempaddr .
   =20
    This is usefull because some distributions does not handle this well:
    When the flag is changed in the kernel, it's often too late, the persis=
tent address is
    already set, and the flag value is never taken into account.
   =20
    With this parameter, it's possible to "preset" the default value of the=
 flag for the
    interfaces.
   =20
    The values [0|1|2+] have the same meaning than the corresponding use_te=
mpaddr flag.
   =20
    Signed-off-by: Julien Aub=C3=A9 <j.aube@laposte.net>

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-par=
ameters.txt
index 01ece1b..b756214 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2081,6 +2081,9 @@ and is between 256 and 4096 characters. It is defined=
 in the file
 	printk.time=3D	Show timing data prefixed to each printk message line
 			Format: <bool>  (1/Y/y=3Denable, 0/N/n=3Ddisable)
=20
+	privacy_default=3D [IPV6]
+			See Documentation/networking/ipv6.txt.
+
 	processor.max_cstate=3D	[HW,ACPI]
 			Limit processor to maximum C-state
 			max_cstate=3D9 overrides any DMI blacklist limit.
diff --git a/Documentation/networking/ipv6.txt b/Documentation/networking/i=
pv6.txt
index 9fd7e21..076b6e6 100644
--- a/Documentation/networking/ipv6.txt
+++ b/Documentation/networking/ipv6.txt
@@ -70,3 +70,20 @@ disable_ipv6
=20
 		No IPv6 addresses will be added to interfaces.
=20
+privacy_default
+
+	Specifies the default value of the flag "use_tempaddr"
+	(aka. Privacy Extension, RFC 3041 and RFC 4941).
+	This is usefull to ensure the value of this flag for
+	distributions that do no takes care of it.
+
+	The possible values are the same as the one used by sysctl:
+
+	0	Privacy Extension (RFC 3041) is not used.
+		This is the default value.
+
+	1	A random address suffix is configured when a Router Advertisement
+		is received,but is not used by default for outgoing communications.
+
+	2	A random address suffix is configured when a Router Advertisement
+		is received, and is used by deault for outgoing communications.
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 848b355..c93ce71 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -15,6 +15,11 @@
 /*
  *	Changes:
  *
+ *  Julien Aub=C3=A9           :   Add a configurable default value for the
+ *		use_tmpaddr flag, which control the behavior of
+ *		the kernel according to the RFC 3041 and 4941.
+ * <j.aube@laposte.net>
+ *
  *	Janos Farkas			:	delete timer on ifdown
  *	<chexum@bankinf.banki.hu>
  *	Andi Kleen			:	kill double kfree on module
@@ -125,6 +130,12 @@ static inline void addrconf_sysctl_unregister(struct i=
net6_dev *idev)
 static int __ipv6_regen_rndid(struct inet6_dev *idev);
 static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr =
*tmpaddr);
 static void ipv6_regen_rndid(unsigned long data);
+
+static int ipv6_default_privacy;
+module_param_named(privacy_default, ipv6_default_privacy, int, 0444);
+MODULE_PARM_DESC(privacy_default, "Set IPv6 privacy extension by default \
+on all interfaces (0,1 or 2)");
+
 #endif
=20
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
@@ -4554,6 +4565,26 @@ static int __net_init addrconf_init_net(struct net *=
net)
 	all =3D &ipv6_devconf;
 	dflt =3D &ipv6_devconf_dflt;
=20
+#ifdef CONFIG_IPV6_PRIVACY
+	if (ipv6_default_privacy =3D=3D 0) {
+		printk(KERN_INFO "IPv6 Privacy Extension "
+							"is disabled by default\n");
+	} else if (ipv6_default_privacy =3D=3D 1) {
+		printk(KERN_INFO "IPv6 Privacy Extension "
+							"is enabled by default\n");
+		all->use_tempaddr  =3D ipv6_default_privacy;
+		dflt->use_tempaddr =3D ipv6_default_privacy;
+	} else if (ipv6_default_privacy >=3D 2) {
+		printk(KERN_INFO "IPv6 Privacy Extension "
+							"is enabled and used by default\n");
+		all->use_tempaddr  =3D ipv6_default_privacy;
+		dflt->use_tempaddr =3D ipv6_default_privacy;
+	} else {
+		printk(KERN_WARNING "IPv6 Privacy Extension "
+	"is disabled by default (invalid value %d)\n", ipv6_default_privacy);
+	}
+#endif
+
 	if (!net_eq(net, &init_net)) {
 		all =3D kmemdup(all, sizeof(ipv6_devconf), GFP_KERNEL);
 		if (all =3D=3D NULL)

--MP_/reQop1X/jU4Zx9Z/avA4491--
