From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: [Ilw] drivers/net/wireless/iwlwifi/dvm/tx.c:456
 iwlagn_tx_skb+0x6c5/0x883()
Date: Tue, 15 Oct 2013 19:11:36 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB301DC4E24@HASMSX103.ger.corp.intel.com>
References: <9010061839.20131015123940@eikelenboom.it>
 <0BA3FCBA62E2DC44AF3030971E174FB301DC46E5@HASMSX103.ger.corp.intel.com>
 <1127865420.20131015151054@eikelenboom.it>
 <0BA3FCBA62E2DC44AF3030971E174FB301DC4AB7@HASMSX103.ger.corp.intel.com>
 <1764863131.20131015210406@eikelenboom.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_0BA3FCBA62E2DC44AF3030971E174FB301DC4E24HASMSX103gercor_"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34192 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756260Ab3JOTLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 15:11:41 -0400
In-Reply-To: <1764863131.20131015210406@eikelenboom.it>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_0BA3FCBA62E2DC44AF3030971E174FB301DC4E24HASMSX103gercor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> > Please apply this:
> > diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c
> b/drivers/net/wireless/iwlwifi/dvm/tx.c
> > index d131f85..5968f19 100644
> > --- a/drivers/net/wireless/iwlwifi/dvm/tx.c
> > +++ b/drivers/net/wireless/iwlwifi/dvm/tx.c
> > @@ -457,8 +457,8 @@ int iwlagn_tx_skb(struct iwl_priv *priv,
> >         WARN_ON_ONCE(is_agg &&
> >                      priv->queue_to_mac80211[txq_id] !=3D info->hw_queu=
e);
> >
> > -       IWL_DEBUG_TX(priv, "TX to [%d|%d] Q:%d - seq: 0x%x\n", sta_id, =
tid,
> > -                    txq_id, seq_number);
> > +       IWL_DEBUG_TX(priv, "TX to [%d|%d] Q:%d info Q %d - seq: 0x%x\n"=
,
> sta_id, tid,
> > +                    txq_id, info->hw_queue, seq_number);
> >
> >         if (iwl_trans_tx(priv->trans, skb, dev_cmd, txq_id))
> >                 goto drop_unlock_sta;
>=20
> > and send the output back to me
>=20
> > Thanks.
>=20

Can you please apply the patch attached (and remove the previous change)?
Thanks.


--_002_0BA3FCBA62E2DC44AF3030971E174FB301DC4E24HASMSX103gercor_
Content-Type: application/octet-stream;
	name="0001-iwlwifi-dvm-don-t-override-mac80211-s-queue-setting.patch"
Content-Description: 0001-iwlwifi-dvm-don-t-override-mac80211-s-queue-setting.patch
Content-Disposition: attachment;
	filename="0001-iwlwifi-dvm-don-t-override-mac80211-s-queue-setting.patch";
	size=1902; creation-date="Tue, 15 Oct 2013 19:09:32 GMT";
	modification-date="Tue, 15 Oct 2013 19:09:50 GMT"
Content-Transfer-Encoding: base64

RnJvbSBmZGRhNzliMjQyMTM0ODMwMzRjZDlhMTczYmQxYjA3ODMwOWNiNGI5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBFbW1hbnVlbCBHcnVtYmFjaCA8ZW1tYW51ZWwuZ3J1bWJhY2hA
aW50ZWwuY29tPgpEYXRlOiBUdWUsIDE1IE9jdCAyMDEzIDIyOjA0OjU0ICswMzAwClN1YmplY3Q6
IFtQQVRDSF0gaXdsd2lmaTogZHZtOiBkb24ndCBvdmVycmlkZSBtYWM4MDIxMSdzIHF1ZXVlIHNl
dHRpbmcKClNpbmNlIHdlIHNldCBJRUVFODAyMTFfSFdfUVVFVUVfQ09OVFJPTCwgd2UgY2FuIGxl
dAptYWM4MDIxMSBkbyB0aGUgcXVldWUgYXNzaWduZW1lbnQgYW5kIGRvbid0IG5lZWQgdG8Kb3Zl
cnJpZGUgaXRzIGRlY2lzaW9ucy4KVGhpcyBpcyB0cnVlIGZvciBvZmZjaGFubmVsIHBhY2tldHMs
IHBhY2tldHMgdG8gIGJlIHNlbnQKYWZ0ZXIgRFRJTSwgYnV0IG5vdCBmb3IgQU1QRFVzIHNpbmNl
IHdlIGhhdmUgYSBzcGVjaWFsCnF1ZXVlIGZvciB0aGVtLiBTbyBmb3IgQU1QRFUsIHdlIHN0aWxs
IG92ZXJyaWRlCmluZm8tPmh3X3F1ZXVlIGJ5IHRoZSBBTVBEVSBxdWV1ZS4KClNpZ25lZC1vZmYt
Ynk6IEVtbWFudWVsIEdydW1iYWNoIDxlbW1hbnVlbC5ncnVtYmFjaEBpbnRlbC5jb20+Ci0tLQog
ZHJpdmVycy9uZXQvd2lyZWxlc3MvaXdsd2lmaS9kdm0vdHguYyB8IDE0ICsrKy0tLS0tLS0tLS0t
CiAxIGZpbGUgY2hhbmdlZCwgMyBpbnNlcnRpb25zKCspLCAxMSBkZWxldGlvbnMoLSkKCmRpZmYg
LS1naXQgYS9kcml2ZXJzL25ldC93aXJlbGVzcy9pd2x3aWZpL2R2bS90eC5jIGIvZHJpdmVycy9u
ZXQvd2lyZWxlc3MvaXdsd2lmaS9kdm0vdHguYwppbmRleCBkMTMxZjg1Li44NjE5NmE1IDEwMDY0
NAotLS0gYS9kcml2ZXJzL25ldC93aXJlbGVzcy9pd2x3aWZpL2R2bS90eC5jCisrKyBiL2RyaXZl
cnMvbmV0L3dpcmVsZXNzL2l3bHdpZmkvZHZtL3R4LmMKQEAgLTQzMywyNyArNDMzLDE5IEBAIGlu
dCBpd2xhZ25fdHhfc2tiKHN0cnVjdCBpd2xfcHJpdiAqcHJpdiwKIAkvKiBDb3B5IE1BQyBoZWFk
ZXIgZnJvbSBza2IgaW50byBjb21tYW5kIGJ1ZmZlciAqLwogCW1lbWNweSh0eF9jbWQtPmhkciwg
aGRyLCBoZHJfbGVuKTsKIAorCXR4cV9pZCA9IGluZm8tPmh3X3F1ZXVlOworCiAJaWYgKGlzX2Fn
ZykKIAkJdHhxX2lkID0gcHJpdi0+dGlkX2RhdGFbc3RhX2lkXVt0aWRdLmFnZy50eHFfaWQ7CiAJ
ZWxzZSBpZiAoaW5mby0+ZmxhZ3MgJiBJRUVFODAyMTFfVFhfQ1RMX1NFTkRfQUZURVJfRFRJTSkg
ewogCQkvKgotCQkgKiBTZW5kIHRoaXMgZnJhbWUgYWZ0ZXIgRFRJTSAtLSB0aGVyZSdzIGEgc3Bl
Y2lhbCBxdWV1ZQotCQkgKiByZXNlcnZlZCBmb3IgdGhpcyBmb3IgY29udGV4dHMgdGhhdCBzdXBw
b3J0IEFQIG1vZGUuCi0JCSAqLwotCQl0eHFfaWQgPSBjdHgtPm1jYXN0X3F1ZXVlOwotCi0JCS8q
CiAJCSAqIFRoZSBtaWNyb2NvZGUgd2lsbCBjbGVhciB0aGUgbW9yZSBkYXRhCiAJCSAqIGJpdCBp
biB0aGUgbGFzdCBmcmFtZSBpdCB0cmFuc21pdHMuCiAJCSAqLwogCQloZHItPmZyYW1lX2NvbnRy
b2wgfD0KIAkJCWNwdV90b19sZTE2KElFRUU4MDIxMV9GQ1RMX01PUkVEQVRBKTsKLQl9IGVsc2Ug
aWYgKGluZm8tPmZsYWdzICYgSUVFRTgwMjExX1RYX0NUTF9UWF9PRkZDSEFOKQotCQl0eHFfaWQg
PSBJV0xfQVVYX1FVRVVFOwotCWVsc2UKLQkJdHhxX2lkID0gY3R4LT5hY190b19xdWV1ZVtza2Jf
Z2V0X3F1ZXVlX21hcHBpbmcoc2tiKV07CisJfQogCi0JV0FSTl9PTl9PTkNFKCFpc19hZ2cgJiYg
dHhxX2lkICE9IGluZm8tPmh3X3F1ZXVlKTsKIAlXQVJOX09OX09OQ0UoaXNfYWdnICYmCiAJCSAg
ICAgcHJpdi0+cXVldWVfdG9fbWFjODAyMTFbdHhxX2lkXSAhPSBpbmZvLT5od19xdWV1ZSk7CiAK
LS0gCjEuOC4xLm1zeXNnaXQuMQoK

--_002_0BA3FCBA62E2DC44AF3030971E174FB301DC4E24HASMSX103gercor_--
