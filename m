From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 15:40:05 -0700
Message-ID: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov>
	 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
	 <fbbce0572843.47fb038c@fnal.gov>
	 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
	 <fba201de4228.47fb3b26@fnal.gov>
	 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
	 <000301c89e81$80124570$6b5ee183@D2GT6T71>
	 <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
	 <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
	 <fc3c25e72104.4804a729@fnal.gov>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_14346_968524.1208299205949"
Cc: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: "Wenji Wu" <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:61421 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761460AbYDOWkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 18:40:06 -0400
Received: by wa-out-1112.google.com with SMTP id m16so3447490waf.23
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 15:40:06 -0700 (PDT)
In-Reply-To: <fc3c25e72104.4804a729@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_14346_968524.1208299205949
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Wenji, can you try this out?  Patch against net-2.6.26.

Thanks,
  -John

------=_Part_14346_968524.1208299205949
Content-Type: text/x-diff;
 name=0001-Increase-the-max_burst-threshold-from-3-to-tp-reord.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ff32520g0
Content-Disposition: attachment;
 filename=0001-Increase-the-max_burst-threshold-from-3-to-tp-reord.patch

RnJvbSA0Y2IyYTlmZDFkNDk3YjAyYmZkZDA2ZjcxYjQ5OWQ0NDFjYTEwYWVlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb2huIEhlZmZuZXIgPGpvaG53aGVmZm5lckBnbWFpbC5jb20+
CkRhdGU6IFR1ZSwgMTUgQXByIDIwMDggMTU6MjY6MzkgLTA3MDAKU3ViamVjdDogW1BBVENIXSBJ
bmNyZWFzZSB0aGUgbWF4X2J1cnN0IHRocmVzaG9sZCBmcm9tIDMgdG8gdHAtPnJlb3JkZXJpbmcu
CgpUaGlzIGNoYW5nZSBpcyBuZWNlc3NhcnkgdG8gYWxsb3cgY3duZCB0byBncm93IGR1cmluZyBw
ZXJzaXN0ZW50CnJlb3JkZXJpbmcuICBDd25kIG1vZGVyYXRpb24gaXMgYXBwbGllZCB3aGVuIGlu
IHRoZSBkaXNvcmRlciBzdGF0ZQphbmQgYW4gYWNrIHRoYXQgZmlsbHMgdGhlIGhvbGUgY29tZXMg
aW4uICBJZiB0aGUgaG9sZSB3YXMgZ3JlYXRlcgp0aGFuIDMgcGFja2V0cywgYnV0IGxlc3MgdGhh
biB0cC0+cmVvcmRlcmluZywgY3duZCB3aWxsIHNocmluayB3aGVuCml0IHNob3VsZCBub3QgaGF2
ZS4KClNpZ25lZC1vZmYtYnk6IEpvaG4gSGVmZm5lciA8amhlZmZuZXJAbmFwYS4obm9uZSk+Ci0t
LQogaW5jbHVkZS9uZXQvdGNwLmggfCAgICA3ICsrKysrLS0KIDEgZmlsZXMgY2hhbmdlZCwgNSBp
bnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3Rj
cC5oIGIvaW5jbHVkZS9uZXQvdGNwLmgKaW5kZXggMmMxNGVkZi4uNjMzMTQ3YyAxMDA2NDQKLS0t
IGEvaW5jbHVkZS9uZXQvdGNwLmgKKysrIGIvaW5jbHVkZS9uZXQvdGNwLmgKQEAgLTc4NywxMSAr
Nzg3LDE0IEBAIGV4dGVybiB2b2lkIHRjcF9lbnRlcl9jd3Ioc3RydWN0IHNvY2sgKnNrLCBjb25z
dCBpbnQgc2V0X3NzdGhyZXNoKTsKIGV4dGVybiBfX3UzMiB0Y3BfaW5pdF9jd25kKHN0cnVjdCB0
Y3Bfc29jayAqdHAsIHN0cnVjdCBkc3RfZW50cnkgKmRzdCk7CiAKIC8qIFNsb3cgc3RhcnQgd2l0
aCBkZWxhY2sgcHJvZHVjZXMgMyBwYWNrZXRzIG9mIGJ1cnN0LCBzbyB0aGF0Ci0gKiBpdCBpcyBz
YWZlICJkZSBmYWN0byIuCisgKiBpdCBpcyBzYWZlICJkZSBmYWN0byIuICBUaGlzIHdpbGwgYmUg
dGhlIGRlZmF1bHQgLSBzYW1lIGFzCisgKiB0aGUgZGVmYXVsdCByZW9yZGVyaW5nIHRocmVzaG9s
ZCAtIGJ1dCBpZiByZW9yZGVyaW5nIGluY3JlYXNlcywKKyAqIHdlIG11c3QgYmUgYWJsZSB0byBh
bGxvdyBjd25kIHRvIGJ1cnN0IGF0IGxlYXN0IHRoaXMgbXVjaCBpbiBvcmRlcgorICogdG8gbm90
IHB1bGwgaXQgYmFjayB3aGVuIGhvbGVzIGFyZSBmaWxsZWQuCiAgKi8KIHN0YXRpYyBfX2lubGlu
ZV9fIF9fdTMyIHRjcF9tYXhfYnVyc3QoY29uc3Qgc3RydWN0IHRjcF9zb2NrICp0cCkKIHsKLQly
ZXR1cm4gMzsKKwlyZXR1cm4gdHAtPnJlb3JkZXJpbmc7CiB9CiAKIC8qIFJldHVybnMgZW5kIHNl
cXVlbmNlIG51bWJlciBvZiB0aGUgcmVjZWl2ZXIncyBhZHZlcnRpc2VkIHdpbmRvdyAqLwotLSAK
MS41LjIuNQoK
------=_Part_14346_968524.1208299205949--
