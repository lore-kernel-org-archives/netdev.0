From: Oskar Andreasson <blueflux@koffein.net>
Subject: [PATCH][RESEND] Update of tcp_syncookies explanation
Date: Tue, 1 Apr 2003 19:33:13 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304011911270.22637-200000@laptop1.agatha>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463810815-689177628-1049217616=:22637"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   "Alexey N. Kuznetsov" <kuznet@ms2.inr.ac.ru>
Content-ID: <Pine.LNX.4.44.0304011920220.22637@laptop1.agatha>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463810815-689177628-1049217616=:22637
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44.0304011920221.22637@laptop1.agatha>

Hi David, Alexey, et al.

This is a patch that fixes/updates the tcp_syncookies explanation in the 
linux/Documentation/networking/ip-sysctl.txt document. 

Basically it reduces some of the "big red lights" set up about using this 
specific feature, and instead explains in more detail why the user should 
be careful about using the syncookies option. 

If anyone has any objections against this patch, please tell me so, with 
an explanation of why! 

[slightly off-topic explanation] 

It seems I got caught in the crossfire between two camps when I started
writing the ipsysctl-tutorial at ipsysctl-tutorial.frozentux.net and at 
first I received some rather nasty mails about not warning enough about 
the syncookies option, so I changed it, at which point I received some 
more poison from the other side for warning about the option at all. 

Hence, my decision has been to walk somewhere on the borderline by simply 
explaining the option, what it does, how it works, and what the cons are, 
without taking up too much space in the kernelspace. 

I believe this is what would be best for the kernel documentation as well. 
If anyone disagrees, see above, send me a mail explaining why you 
disagree.

Thanks!

----
Oskar Andreasson
http://www.frozentux.net
http://iptables-tutorial.frozentux.net
http://ipsysctl-tutorial.frozentux.net
mailto:blueflux@koffein.net

---1463810815-689177628-1049217616=:22637
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME="2.4.19.docs.net.ip-sysctl.txt-2.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0304011920160.22637@laptop1.agatha>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="2.4.19.docs.net.ip-sysctl.txt-2.patch"

ZGlmZiAtdXIgbGludXgtMi40LjE5L0RvY3VtZW50YXRpb24vbmV0d29ya2lu
Zy9pcC1zeXNjdGwudHh0IGxpbnV4LTIuNC4xOS5uZXcvRG9jdW1lbnRhdGlv
bi9uZXR3b3JraW5nL2lwLXN5c2N0bC50eHQNCi0tLSBsaW51eC0yLjQuMTkv
RG9jdW1lbnRhdGlvbi9uZXR3b3JraW5nL2lwLXN5c2N0bC50eHQJU2F0IEF1
ZyAgMyAwMjozOTo0MiAyMDAyDQorKysgbGludXgtMi40LjE5Lm5ldy9Eb2N1
bWVudGF0aW9uL25ldHdvcmtpbmcvaXAtc3lzY3RsLnR4dAlTdW4gTm92IDEw
IDE4OjEzOjI2IDIwMDINCkBAIC0xNjIsNyArMTYyLDcgQEANCiAJb3ZlcmZs
b3dzLiBUaGlzIGlzIHRvIHByZXZlbnQgYWdhaW5zdCB0aGUgY29tbW9uICdz
eW4gZmxvb2QgYXR0YWNrJw0KIAlEZWZhdWx0OiBGQUxTRQ0KIA0KLQlOb3Rl
LCB0aGF0IHN5bmNvb2tpZXMgaXMgZmFsbGJhY2sgZmFjaWxpdHkuDQorCU5v
dGUsIHRoYXQgc3luY29va2llcyBpcyBhIGZhbGxiYWNrIGZhY2lsaXR5Lg0K
IAlJdCBNVVNUIE5PVCBiZSB1c2VkIHRvIGhlbHAgaGlnaGx5IGxvYWRlZCBz
ZXJ2ZXJzIHRvIHN0YW5kDQogCWFnYWluc3QgbGVnYWwgY29ubmVjdGlvbiBy
YXRlLiBJZiB5b3Ugc2VlIHN5bmZsb29kIHdhcm5pbmdzDQogCWluIHlvdXIg
bG9ncywgYnV0IGludmVzdGlnYXRpb24Jc2hvd3MgdGhhdCB0aGV5IG9jY3Vy
DQpAQCAtMTcwLDEyICsxNzAsMTggQEANCiAJYW5vdGhlciBwYXJhbWV0ZXJz
IHVudGlsIHRoaXMgd2FybmluZyBkaXNhcHBlYXIuDQogCVNlZTogdGNwX21h
eF9zeW5fYmFja2xvZywgdGNwX3N5bmFja19yZXRyaWVzLCB0Y3BfYWJvcnRf
b25fb3ZlcmZsb3cuDQogDQotCXN5bmNvb2tpZXMgc2VyaW91c2x5IHZpb2xh
dGUgVENQIHByb3RvY29sLCBkbyBub3QgYWxsb3cNCi0JdG8gdXNlIFRDUCBl
eHRlbnNpb25zLCBjYW4gcmVzdWx0IGluIHNlcmlvdXMgZGVncmFkYXRpb24N
Ci0Jb2Ygc29tZSBzZXJ2aWNlcyAoZi5lLiBTTVRQIHJlbGF5aW5nKSwgdmlz
aWJsZSBub3QgYnkgeW91LA0KLQlidXQgeW91ciBjbGllbnRzIGFuZCByZWxh
eXMsIGNvbnRhY3RpbmcgeW91LiBXaGlsZSB5b3Ugc2VlDQotCXN5bmZsb29k
IHdhcm5pbmdzIGluIGxvZ3Mgbm90IGJlaW5nIHJlYWxseSBmbG9vZGVkLCB5
b3VyIHNlcnZlcg0KLQlpcyBzZXJpb3VzbHkgbWlzY29uZmlndXJlZC4NCisJ
VGhlIHRjcF9zeW5jb29raWVzIG9wdGlvbiBtZWFucyB0aGF0IHdoZW4gdGhl
IG1hY2hpbmUgaGFzIG1vcmUgdGhhbiANCisJdGNwX21heF9zeW5fYmFja2xv
ZyBTWU4gcGFja2V0cyBpbiB0aGUgcXVldWUsIGl0IHdpbGwgcmV2ZXJ0IHRv
IA0KKwlzZW5kaW5nIG91dCBTWU4gY29va2llcy4gdGNwX3N5bmNvb2tpZXMg
ZGVwZW5kcyBvbiBhIHNwZWNpZmljYWxseSANCisJZ3JhZnRlZCBUQ1AgU2Vx
dWVuY2UgbnVtYmVyLCB3aGljaCB0aGUgU1lOIGZsb29kZXIgbXVzdCBndWVz
cyB0aGUgDQorCWNvcnJlY3QgbnVtYmVyIG9mLCB1bmxlc3MgaGUgaXMgYWN0
dWFsbHkgcmVjZWl2aW5nIHRoZSBTWU4vQUNLIHRvDQorCWhpbXNlbGYuIA0K
Kw0KKwlXaGVuIFNZTiBjb29raWVzIGFyZSB1c2VkLCBhbGwgbmV3bHkgb3Bl
bmVkIGNvbm5lY3Rpb25zIHdpbGwgYmUgdW5hYmxlDQorCXRvIHVzZSBhbnkg
YWR2YW5jZWQgZmVhdHVyZXMgbGlrZSBFQ04sIFNBQ0sgb3IgVGltZXN0YW1w
cy4gVGhpcyBtYXkgDQorCXJlc3VsdCBpbiBzZXJpb3VzIGRlZ3JhZGF0aW9u
IG9mIHNvbWUgc2VydmljZXMsIGFuZCBpZiB5b3Ugc2VlIA0KKwlzeW5mbG9v
ZCB3YXJuaW5ncyBpbiB5b3VyIGxvZ3MsIGJ1dCB5b3UgYXJlIG5vdCBiZWlu
ZyBmbG9vZGVkLCB5b3VyIA0KKwlzZXJ2ZXIgbWF5IGJlIG1pc2NvbmZpZ3Vy
ZWQuDQogDQogdGNwX3N0ZHVyZyAtIEJPT0xFQU4NCiAJVXNlIHRoZSBIb3N0
IHJlcXVpcmVtZW50cyBpbnRlcnByZXRhdGlvbiBvZiB0aGUgVENQIHVyZyBw
b2ludGVyIGZpZWxkLg0K
---1463810815-689177628-1049217616=:22637--
