From: Wensong Zhang <wensong@linux-vs.org>
Subject: [2.4 PATCH] Fix IPVS ftp to use cp->vaddr
Date: Sat, 18 Oct 2003 14:24:11 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310181357140.6525-200000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463760943-1531064384-1066458251=:6525"
Cc: "David S. Miller" <davem@redhat.com>, Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463760943-1531064384-1066458251=:6525
Content-Type: TEXT/PLAIN; charset=US-ASCII



Hi,

Here is a minor patch for IPVS in the kernel 2.4. It is to fix ip_vs_ftp 
to use cp->vaddr because iph->daddr is already mangled before calling 
ip_vs_ftp_in.

Please check and apply it.

Thanks,

Wensong

---1463760943-1531064384-1066458251=:6525
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="linux-2.4-ipvs-ftp.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0310181424110.6525@penguin.linux-vs.org>
Content-Description: 
Content-Disposition: attachment; filename="linux-2.4-ipvs-ftp.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTE5OCAgLT4gMS4xMTk5IA0KIwlu
ZXQvaXB2NC9pcHZzL2lwX3ZzX2Z0cC5jCTEuMiAgICAgLT4gMS4zICAgIA0K
Iw0KIyBUaGUgZm9sbG93aW5nIGlzIHRoZSBCaXRLZWVwZXIgQ2hhbmdlU2V0
IExvZw0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQ0KIyAwMy8xMC8xNwl3ZW5zb25nQGxpbnV4LXZzLm9yZwkxLjEx
OTkNCiMgW0lQVlNdIEZpeCBpcF92c19mdHAgdG8gdXNlIGNwLT52YWRkciBi
ZWNhdXNlIGlwaC0+ZGFkZHIgaXMgYWxyZWFkeSBtYW5nbGVkDQojIA0KIyAt
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0K
Iw0KZGlmZiAtTnJ1IGEvbmV0L2lwdjQvaXB2cy9pcF92c19mdHAuYyBiL25l
dC9pcHY0L2lwdnMvaXBfdnNfZnRwLmMNCi0tLSBhL25ldC9pcHY0L2lwdnMv
aXBfdnNfZnRwLmMJRnJpIE9jdCAxNyAyMjo0Mzo1NyAyMDAzDQorKysgYi9u
ZXQvaXB2NC9pcHZzL2lwX3ZzX2Z0cC5jCUZyaSBPY3QgMTcgMjI6NDM6NTcg
MjAwMw0KQEAgLTMwNCwxMSArMzA0LDEyIEBADQogCSAqLw0KIAlJUF9WU19E
QkcoMS1kZWJ1ZywgInByb3RvY29sICVzICV1LiV1LiV1LiV1OiVkICV1LiV1
LiV1LiV1OiVkXG4iLA0KIAkJICBpcF92c19wcm90b19uYW1lKGlwaC0+cHJv
dG9jb2wpLA0KLQkJICBOSVBRVUFEKHRvKSwgbnRvaHMocG9ydCksIE5JUFFV
QUQoaXBoLT5kYWRkciksIDApOw0KKwkJICBOSVBRVUFEKHRvKSwgbnRvaHMo
cG9ydCksDQorCQkgIE5JUFFVQUQoY3AtPnZhZGRyKSwgbnRvaHMoY3AtPnZw
b3J0KSAtIDEpOw0KIA0KIAluX2NwID0gaXBfdnNfY29ubl9pbl9nZXQoaXBo
LT5wcm90b2NvbCwNCiAJCQkJIHRvLCBwb3J0LA0KLQkJCQkgaXBoLT5kYWRk
ciwgaHRvbnMobnRvaHMoY3AtPnZwb3J0KS0xKSk7DQorCQkJCSBjcC0+dmFk
ZHIsIGh0b25zKG50b2hzKGNwLT52cG9ydCktMSkpOw0KIAlpZiAoIW5fY3Ap
IHsNCiAJCW5fY3AgPSBpcF92c19jb25uX25ldyhJUFBST1RPX1RDUCwNCiAJ
CQkJICAgICAgdG8sIHBvcnQsDQo=
---1463760943-1531064384-1066458251=:6525--
