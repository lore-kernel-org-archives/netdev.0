From: Wensong Zhang <wensong@linux-vs.org>
Subject: [2.6 PATCH] Fix IPVS sync state check
Date: Mon, 13 Oct 2003 23:15:26 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310132306490.1216-200000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463760943-416249943-1066058126=:1216"
Cc: "David S. Miller" <davem@redhat.com>, Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463760943-416249943-1066058126=:1216
Content-Type: TEXT/PLAIN; charset=US-ASCII



Hi,

Here is a one-line fix in the sync state check for the connection to be
synchronized. Since both the primay and the backup IPVS sync daemon can be
started in a box at a time now, we must check if the MASTER bit is set in
the sync state exactly.

Please check and apply it.

Thanks,

Wensong

---1463760943-416249943-1066058126=:1216
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ipvs-sync-state.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0310132315260.1216@penguin.linux-vs.org>
Content-Description: 
Content-Disposition: attachment; filename="ipvs-sync-state.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTM0NiAgLT4gMS4xMzQ3IA0KIwlu
ZXQvaXB2NC9pcHZzL2lwX3ZzX2NvcmUuYwkxLjYgICAgIC0+IDEuNyAgICAN
CiMNCiMgVGhlIGZvbGxvd2luZyBpcyB0aGUgQml0S2VlcGVyIENoYW5nZVNl
dCBMb2cNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0NCiMgMDMvMTAvMTMJd2Vuc29uZ0BsaW51eC12cy5vcmcJMS4x
MzQ3DQojIFtJUFZTXSBGaXggdGhlIHN5bmMgc3RhdGUgY2hlY2sgZm9yIGNv
bm5lY3Rpb24gdG8gYmUgc3luY2hyb25pemVkDQojIA0KIyBQYXRjaCBmcm9t
IEhvcm1zIDxob3Jtc0B2ZXJnZW5ldC5uZXQ+DQojIA0KIyBTaW5jZSBib3Ro
IHRoZSBwcmltYXkgYW5kIHRoZSBiYWNrdXAgc3luYyBkYWVtb24gY2FuIGJl
IHN0YXJ0ZWQgaW4gYSBib3gNCiMgYXQgYSB0aW1lLCB3ZSBtdXN0IGp1c3Qg
Y2hlY2sgaWYgdGhlIE1BU1RFUiBiaXQgaXMgc2V0IGluIHRoZSBzeW5jIHN0
YXRlLg0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQ0KIw0KZGlmZiAtTnJ1IGEvbmV0L2lwdjQvaXB2cy9pcF92c19j
b3JlLmMgYi9uZXQvaXB2NC9pcHZzL2lwX3ZzX2NvcmUuYw0KLS0tIGEvbmV0
L2lwdjQvaXB2cy9pcF92c19jb3JlLmMJTW9uIE9jdCAxMyAyMzowNDo1MiAy
MDAzDQorKysgYi9uZXQvaXB2NC9pcHZzL2lwX3ZzX2NvcmUuYwlNb24gT2N0
IDEzIDIzOjA0OjUyIDIwMDMNCkBAIC0xMDQ0LDcgKzEwNDQsNyBAQA0KIAkv
KiBpbmNyZWFzZSBpdHMgcGFja2V0IGNvdW50ZXIgYW5kIGNoZWNrIGlmIGl0
IGlzIG5lZWRlZA0KIAkgICB0byBiZSBzeW5jaHJvbml6ZWQgKi8NCiAJYXRv
bWljX2luYygmY3AtPmluX3BrdHMpOw0KLQlpZiAoaXBfdnNfc3luY19zdGF0
ZSA9PSBJUF9WU19TVEFURV9NQVNURVIgJiYNCisJaWYgKChpcF92c19zeW5j
X3N0YXRlICYgSVBfVlNfU1RBVEVfTUFTVEVSKSAmJg0KIAkgICAgKGNwLT5w
cm90b2NvbCAhPSBJUFBST1RPX1RDUCB8fA0KIAkgICAgIGNwLT5zdGF0ZSA9
PSBJUF9WU19UQ1BfU19FU1RBQkxJU0hFRCkgJiYNCiAJICAgIChhdG9taWNf
cmVhZCgmY3AtPmluX3BrdHMpICUgc3lzY3RsX2lwX3ZzX3N5bmNfdGhyZXNo
b2xkWzFdDQo=
---1463760943-416249943-1066058126=:1216--
