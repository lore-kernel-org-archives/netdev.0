From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.4/2.6] ipvs: improve conn rehashing, other fixes
Date: Tue, 23 Mar 2004 10:48:40 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403231045560.1157@u.domain.uli>
References: <20040321230703.408d2240.davem@redhat.com>
 <Pine.LNX.4.44.0403230036130.3318-600000@penguin.linux-vs.org>
 <20040322183641.68ecb8a3.davem@redhat.com> <Pine.LNX.4.58.0403231027420.1157@u.domain.uli>
 <20040323004006.14b2373e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-879398989-1080031720=:1157"
Cc: wensong@linux-vs.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040323004006.14b2373e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-879398989-1080031720=:1157
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

On Tue, 23 Mar 2004, David S. Miller wrote:

> On Tue, 23 Mar 2004 10:34:54 +0200 (EET)
> Julian Anastasov <ja@ssi.bg> wrote:
>
> > 	It was the old version. Please, apply everything sent from
> > Wensong. The old versions protect only the list which is not needed
> > on edit but the new versions from Wensong ensure that the service is
> > updated safely while there are no other CPUs using the schedulers.
>
> Sorry, wires got crossed.  Julian/Wensong, could you please resend
> that ip_vs_ctl.c locking change under seperate cover then?

	I still keep them, attached.

Regards

--
Julian Anastasov <ja@ssi.bg>
--1607745702-879398989-1080031720=:1157
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="linux-2.4-ipvs-updsvc.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0403231048400.1157@u.domain.uli>
Content-Description: 2.4 - update_service
Content-Disposition: attachment; filename="linux-2.4-ipvs-updsvc.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTMzNiAgLT4gMS4xMzM3IA0KIwlu
ZXQvaXB2NC9pcHZzL2lwX3ZzX2N0bC5jCTEuNSAgICAgLT4gMS42ICAgIA0K
Iw0KIyBUaGUgZm9sbG93aW5nIGlzIHRoZSBCaXRLZWVwZXIgQ2hhbmdlU2V0
IExvZw0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQ0KIyAwNC8wMy8yMgl3ZW5zb25nQGxpbnV4LXZzLm9yZwkxLjEz
MzcNCiMgW0lQVlNdIEZpeCB0byBob2xkIHRoZSBsb2NrIGJlZm9yZSB1cGRh
dGluZyBhIHNlcnZpY2UNCiMgDQojIEJyZXR0IEUuIDxicmV0dHNwYW1hY2N0
QGZhc3RjbGljay5jb20+IG5vdGljZWQgdGhlIG1pc3Npbmcgc2VydmljZSBs
b2NrDQojIGZvciBlZGl0aW5nIGRlc3QuDQojIA0KIyBKdWxpYW4gQW5hc3Rh
c292IDxqYUBzc2kuYmc+IHByb3ZpZGVkIHRoZSBwYXRjaC4NCiMgDQojIC0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQoj
DQpkaWZmIC1OcnUgYS9uZXQvaXB2NC9pcHZzL2lwX3ZzX2N0bC5jIGIvbmV0
L2lwdjQvaXB2cy9pcF92c19jdGwuYw0KLS0tIGEvbmV0L2lwdjQvaXB2cy9p
cF92c19jdGwuYwlNb24gTWFyIDIyIDIzOjEwOjQ3IDIwMDQNCisrKyBiL25l
dC9pcHY0L2lwdnMvaXBfdnNfY3RsLmMJTW9uIE1hciAyMiAyMzoxMDo0NyAy
MDA0DQpAQCAtODg5LDggKzg4OSwxNSBAQA0KIA0KIAlfX2lwX3ZzX3VwZGF0
ZV9kZXN0KHN2YywgZGVzdCwgdXIpOw0KIA0KKwl3cml0ZV9sb2NrX2JoKCZf
X2lwX3ZzX3N2Y19sb2NrKTsNCisNCisJLyogV2FpdCB1bnRpbCBhbGwgb3Ro
ZXIgc3ZjIHVzZXJzIGdvIGF3YXkgKi8NCisJd2hpbGUgKGF0b21pY19yZWFk
KCZzdmMtPnVzZWNudCkgPiAxKSB7fTsNCisNCiAJLyogY2FsbCB0aGUgdXBk
YXRlX3NlcnZpY2UsIGJlY2F1c2Ugc2VydmVyIHdlaWdodCBtYXkgYmUgY2hh
bmdlZCAqLw0KIAlzdmMtPnNjaGVkdWxlci0+dXBkYXRlX3NlcnZpY2Uoc3Zj
KTsNCisNCisJd3JpdGVfdW5sb2NrX2JoKCZfX2lwX3ZzX3N2Y19sb2NrKTsN
CiANCiAJTGVhdmVGdW5jdGlvbigyKTsNCiANCg==

--1607745702-879398989-1080031720=:1157
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="linux-2.6-ipvs-updsvc.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0403231048401.1157@u.domain.uli>
Content-Description: 2.6 - update_service
Content-Disposition: attachment; filename="linux-2.6-ipvs-updsvc.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTgzMCAgLT4gMS4xODMxIA0KIwlu
ZXQvaXB2NC9pcHZzL2lwX3ZzX2N0bC5jCTEuMTQgICAgLT4gMS4xNSAgIA0K
Iw0KIyBUaGUgZm9sbG93aW5nIGlzIHRoZSBCaXRLZWVwZXIgQ2hhbmdlU2V0
IExvZw0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQ0KIyAwNC8wMy8yMwl3ZW5zb25nQGxpbnV4LXZzLm9yZwkxLjE4
MzENCiMgW0lQVlNdIEZpeCB0byBob2xkIHRoZSBsb2NrIGJlZm9yZSB1cGRh
dGluZyBhIHNlcnZpY2UNCiMgDQojIEJyZXR0IEUuIDxicmV0dHNwYW1hY2N0
QGZhc3RjbGljay5jb20+IG5vdGljZWQgdGhlIG1pc3Npbmcgc2VydmljZSBs
b2NrDQojIGZvciBlZGl0aW5nIGRlc3QuDQojIA0KIyBKdWxpYW4gQW5hc3Rh
c292IDxqYUBzc2kuYmc+IHByb3ZpZGVkIHRoZSBwYXRjaC4NCiMgLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCiMNCmRp
ZmYgLU5ydSBhL25ldC9pcHY0L2lwdnMvaXBfdnNfY3RsLmMgYi9uZXQvaXB2
NC9pcHZzL2lwX3ZzX2N0bC5jDQotLS0gYS9uZXQvaXB2NC9pcHZzL2lwX3Zz
X2N0bC5jCVR1ZSBNYXIgMjMgMDA6NTc6NTggMjAwNA0KKysrIGIvbmV0L2lw
djQvaXB2cy9pcF92c19jdGwuYwlUdWUgTWFyIDIzIDAwOjU3OjU4IDIwMDQN
CkBAIC04OTgsOCArODk4LDE1IEBADQogDQogCV9faXBfdnNfdXBkYXRlX2Rl
c3Qoc3ZjLCBkZXN0LCB1ZGVzdCk7DQogDQorCXdyaXRlX2xvY2tfYmgoJl9f
aXBfdnNfc3ZjX2xvY2spOw0KKw0KKwkvKiBXYWl0IHVudGlsIGFsbCBvdGhl
ciBzdmMgdXNlcnMgZ28gYXdheSAqLw0KKwl3aGlsZSAoYXRvbWljX3JlYWQo
JnN2Yy0+dXNlY250KSA+IDEpIHt9Ow0KKw0KIAkvKiBjYWxsIHRoZSB1cGRh
dGVfc2VydmljZSwgYmVjYXVzZSBzZXJ2ZXIgd2VpZ2h0IG1heSBiZSBjaGFu
Z2VkICovDQogCXN2Yy0+c2NoZWR1bGVyLT51cGRhdGVfc2VydmljZShzdmMp
Ow0KKw0KKwl3cml0ZV91bmxvY2tfYmgoJl9faXBfdnNfc3ZjX2xvY2spOw0K
IA0KIAlMZWF2ZUZ1bmN0aW9uKDIpOw0KIA0K

--1607745702-879398989-1080031720=:1157--
