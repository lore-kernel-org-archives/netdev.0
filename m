From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Convert to net_device_ops
Date: Tue, 24 Mar 2009 11:37:11 +0100
Message-ID: <OFA0B803BB.DEC93B9A-ONC1257583.0039CF3E-C1257583.003A55BA@transmode.se>
References: <OF2EE08546.DF677136-ONC1257582.0037C87E-C1257582.00388BCE@transmode.se>
	<20090323.114928.01832203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 003A55AEC1257583_="
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090323.114928.01832203.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--=_mixed 003A55AEC1257583_=
Content-Type: text/plain; charset="US-ASCII"

David Miller <davem@davemloft.net> wrote on 23/03/2009 19:49:28:
> 
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Mon, 23 Mar 2009 11:17:39 +0100
> 
> > Sorry for the WS damaged patch, but my current company mailer cannot
> > handle inline patches. Due to this we are setting up a new mail system
> > but it will be a few days before this is ready.
> > Therefore I am attaching this patch as well, use that one
> > to apply instaed of the inline variant.
> 
> This patch has other problems, anyways.
> 
> > +#if 0
> > +/* not yet */
> > +       .ndo_set_mac_address    = ucc_geth_set_mac_address,
> > +       .ndo_change_mtu         = ucc_geth_change_mtu,
> > +       .ndo_do_ioctl           = ucc_geth_do_ioctl,
> > +#endif
> 
> Don't do stuff like this, please.  Even the code you are
> copying from doesn't have the set_mac_address method
> assignment proceted by #if 0 stuff.
> 
> Just get rid of all the unused stuff completely.

OK, here is a new version. The #if 0 ..#endif has been removed.


 Jocke

--=_mixed 003A55AEC1257583_=
Content-Type: application/octet-stream; name="0001-ucc_geth-Convert-to-net_device_ops.patch"
Content-Disposition: attachment; filename="0001-ucc_geth-Convert-to-net_device_ops.patch"
Content-Transfer-Encoding: base64

RnJvbSA3ZjFjNmYzMmRmMTE0Y2ZkYTc1MDA0OWJlNGQyNjAxYWY3NDE3NGE4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb2FraW0gVGplcm5sdW5kIDxKb2FraW0uVGplcm5sdW5kQHRy
YW5zbW9kZS5zZT4KRGF0ZTogRnJpLCAyMCBNYXIgMjAwOSAyMTowOToxNCArMDEwMApTdWJqZWN0
OiBbUEFUQ0hdIHVjY19nZXRoOiBDb252ZXJ0IHRvIG5ldF9kZXZpY2Vfb3BzCgotLS0KIGRyaXZl
cnMvbmV0L3VjY19nZXRoLmMgfCAgIDIyICsrKysrKysrKysrKystLS0tLS0tLS0KIDEgZmlsZXMg
Y2hhbmdlZCwgMTMgaW5zZXJ0aW9ucygrKSwgOSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9k
cml2ZXJzL25ldC91Y2NfZ2V0aC5jIGIvZHJpdmVycy9uZXQvdWNjX2dldGguYwppbmRleCA3NzE2
MjM5Li40MmIxYTUwIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC91Y2NfZ2V0aC5jCisrKyBiL2Ry
aXZlcnMvbmV0L3VjY19nZXRoLmMKQEAgLTM1MDEsNiArMzUwMSwxOCBAQCBzdGF0aWMgcGh5X2lu
dGVyZmFjZV90IHRvX3BoeV9pbnRlcmZhY2UoY29uc3QgY2hhciAqcGh5X2Nvbm5lY3Rpb25fdHlw
ZSkKIAlyZXR1cm4gUEhZX0lOVEVSRkFDRV9NT0RFX01JSTsKIH0KIAorc3RhdGljIGNvbnN0IHN0
cnVjdCBuZXRfZGV2aWNlX29wcyB1Y2NfZ2V0aF9uZXRkZXZfb3BzID0geworCS5uZG9fb3BlbgkJ
PSB1Y2NfZ2V0aF9vcGVuLAorCS5uZG9fc3RvcAkJPSB1Y2NfZ2V0aF9jbG9zZSwKKwkubmRvX3N0
YXJ0X3htaXQJCT0gdWNjX2dldGhfc3RhcnRfeG1pdCwKKwkubmRvX3ZhbGlkYXRlX2FkZHIJPSBl
dGhfdmFsaWRhdGVfYWRkciwKKwkubmRvX3NldF9tdWx0aWNhc3RfbGlzdAk9IHVjY19nZXRoX3Nl
dF9tdWx0aSwKKwkubmRvX3R4X3RpbWVvdXQJCT0gdWNjX2dldGhfdGltZW91dCwKKyNpZmRlZiBD
T05GSUdfTkVUX1BPTExfQ09OVFJPTExFUgorCS5uZG9fcG9sbF9jb250cm9sbGVyCT0gdWNjX25l
dHBvbGwsCisjZW5kaWYKK307CisKIHN0YXRpYyBpbnQgdWNjX2dldGhfcHJvYmUoc3RydWN0IG9m
X2RldmljZSogb2ZkZXYsIGNvbnN0IHN0cnVjdCBvZl9kZXZpY2VfaWQgKm1hdGNoKQogewogCXN0
cnVjdCBkZXZpY2UgKmRldmljZSA9ICZvZmRldi0+ZGV2OwpAQCAtMzcxNiwxOSArMzcyOCwxMSBA
QCBzdGF0aWMgaW50IHVjY19nZXRoX3Byb2JlKHN0cnVjdCBvZl9kZXZpY2UqIG9mZGV2LCBjb25z
dCBzdHJ1Y3Qgb2ZfZGV2aWNlX2lkICptYQogCiAJLyogRmlsbCBpbiB0aGUgZGV2IHN0cnVjdHVy
ZSAqLwogCXVlY19zZXRfZXRodG9vbF9vcHMoZGV2KTsKLQlkZXYtPm9wZW4gPSB1Y2NfZ2V0aF9v
cGVuOwotCWRldi0+aGFyZF9zdGFydF94bWl0ID0gdWNjX2dldGhfc3RhcnRfeG1pdDsKLQlkZXYt
PnR4X3RpbWVvdXQgPSB1Y2NfZ2V0aF90aW1lb3V0OworCWRldi0+bmV0ZGV2X29wcyA9ICZ1Y2Nf
Z2V0aF9uZXRkZXZfb3BzOwogCWRldi0+d2F0Y2hkb2dfdGltZW8gPSBUWF9USU1FT1VUOwogCUlO
SVRfV09SSygmdWdldGgtPnRpbWVvdXRfd29yaywgdWNjX2dldGhfdGltZW91dF93b3JrKTsKIAlu
ZXRpZl9uYXBpX2FkZChkZXYsICZ1Z2V0aC0+bmFwaSwgdWNjX2dldGhfcG9sbCwgVUNDX0dFVEhf
REVWX1dFSUdIVCk7Ci0jaWZkZWYgQ09ORklHX05FVF9QT0xMX0NPTlRST0xMRVIKLQlkZXYtPnBv
bGxfY29udHJvbGxlciA9IHVjY19uZXRwb2xsOwotI2VuZGlmCi0JZGV2LT5zdG9wID0gdWNjX2dl
dGhfY2xvc2U7Ci0vLyAgICBkZXYtPmNoYW5nZV9tdHUgPSB1Y2NfZ2V0aF9jaGFuZ2VfbXR1Owog
CWRldi0+bXR1ID0gMTUwMDsKLQlkZXYtPnNldF9tdWx0aWNhc3RfbGlzdCA9IHVjY19nZXRoX3Nl
dF9tdWx0aTsKIAogCXVnZXRoLT5tc2dfZW5hYmxlID0gbmV0aWZfbXNnX2luaXQoZGVidWcubXNn
X2VuYWJsZSwgVUdFVEhfTVNHX0RFRkFVTFQpOwogCXVnZXRoLT5waHlfaW50ZXJmYWNlID0gcGh5
X2ludGVyZmFjZTsKLS0gCjEuNi4xLjMKCg==

--=_mixed 003A55AEC1257583_=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--=_mixed 003A55AEC1257583_=--
