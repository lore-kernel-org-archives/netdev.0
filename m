From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Sun, 6 Mar 2005 18:55:58 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0503061850390.23235@kaber.coreworks.de>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au> <422AF8D0.3010905@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="279739137-1600102413-1110131758=:23235"
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <422AF8D0.3010905@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--279739137-1600102413-1110131758=:23235
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

Fixed a missing pair of parentheses - ! has precedence over bitwise AND.

On Sun, 6 Mar 2005, Patrick McHardy wrote:
> How about this one ? It keeps the DST_XFRM_TUNNEL flag and sets it on
> the first xfrm_dst in a bundle. I know it doesn't really belong there,
> but the alternatives are walking through the bundle an additional time
> or having xfrm_bundle_ok() return if it is a tunnel-mode bundle, but in
> that case we can only compare tos etc after the call to
> xfrm_bundle_ok(), which is rather expensive. I also moved the oif check
> to the checks performed only in transport mode, this reduces the number
> of cached bundles in tunnel mode to one per src/dst if the selector
> isn't narrower than that.
>
> Signed-off-by: Patrick McHardy <kaber@trash.net>
--279739137-1600102413-1110131758=:23235
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=x
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.62.0503061855580.23235@kaber.coreworks.de>
Content-Description: 
Content-Disposition: attachment; filename=x

PT09PT0gaW5jbHVkZS9uZXQvZHN0LmggMS4yNiB2cyBlZGl0ZWQgPT09PT0N
Ci0tLSAxLjI2L2luY2x1ZGUvbmV0L2RzdC5oCTIwMDUtMDItMTUgMjM6MjM6
MTAgKzAxOjAwDQorKysgZWRpdGVkL2luY2x1ZGUvbmV0L2RzdC5oCTIwMDUt
MDMtMDYgMTI6NTA6NTQgKzAxOjAwDQpAQCAtNDgsNiArNDgsNyBAQA0KICNk
ZWZpbmUgRFNUX05PWEZSTQkJMg0KICNkZWZpbmUgRFNUX05PUE9MSUNZCQk0
DQogI2RlZmluZSBEU1RfTk9IQVNICQk4DQorI2RlZmluZSBEU1RfWEZSTV9U
VU5ORUwJCTE2DQogCXVuc2lnbmVkIGxvbmcJCWxhc3R1c2U7DQogCXVuc2ln
bmVkIGxvbmcJCWV4cGlyZXM7DQogDQo9PT09PSBuZXQvaXB2NC94ZnJtNF9w
b2xpY3kuYyAxLjE1IHZzIGVkaXRlZCA9PT09PQ0KLS0tIDEuMTUvbmV0L2lw
djQveGZybTRfcG9saWN5LmMJMjAwNS0wMy0wNSAwMTo1ODo0MSArMDE6MDAN
CisrKyBlZGl0ZWQvbmV0L2lwdjQveGZybTRfcG9saWN5LmMJMjAwNS0wMy0w
NiAxODo0OToyMyArMDE6MDANCkBAIC0zMCw5ICszMCwxNSBAQA0KIAlyZWFk
X2xvY2tfYmgoJnBvbGljeS0+bG9jayk7DQogCWZvciAoZHN0ID0gcG9saWN5
LT5idW5kbGVzOyBkc3Q7IGRzdCA9IGRzdC0+bmV4dCkgew0KIAkJc3RydWN0
IHhmcm1fZHN0ICp4ZHN0ID0gKHN0cnVjdCB4ZnJtX2RzdCopZHN0Ow0KLQkJ
aWYgKHhkc3QtPnUucnQuZmwub2lmID09IGZsLT5vaWYgJiYJLypYWFgqLw0K
LQkJICAgIHhkc3QtPnUucnQuZmwuZmw0X2RzdCA9PSBmbC0+Zmw0X2RzdCAm
Jg0KKwkJaWYgKHhkc3QtPnUucnQuZmwuZmw0X2RzdCA9PSBmbC0+Zmw0X2Rz
dCAmJg0KIAkgICAgCSAgICB4ZHN0LT51LnJ0LmZsLmZsNF9zcmMgPT0gZmwt
PmZsNF9zcmMgJiYNCisJCSAgICAoZHN0LT5mbGFncyAmIERTVF9YRlJNX1RV
Tk5FTCB8fA0KKwkJICAgICAoISgoeGRzdC0+dS5ydC5mbC5mbDRfdG9zIF4g
ZmwtPmZsNF90b3MpICYgDQorCQkgICAgICAgICAgICAgICAgICAgKElQVE9T
X1JUX01BU0t8UlRPX09OTElOSykpICYmDQorI2lmZGVmIENPTkZJR19JUF9S
T1VURV9GV01BUksNCisJCSAgICAgIHhkc3QtPnUucnQuZmwuZmw0X2Z3bWFy
ayA9PSBmbC0+Zmw0X2Z3bWFyayAmJg0KKyNlbmRpZg0KKwkJICAgICAgeGRz
dC0+dS5ydC5mbC5vaWYgPT0gZmwtPm9pZikpICYmDQogCQkgICAgeGZybV9i
dW5kbGVfb2soeGRzdCwgZmwsIEFGX0lORVQpKSB7DQogCQkJZHN0X2Nsb25l
KGRzdCk7DQogCQkJYnJlYWs7DQpAQCAtOTcsNiArMTAzLDcgQEANCiAJCWVy
ciA9IHhmcm1fZHN0X2xvb2t1cCgoc3RydWN0IHhmcm1fZHN0KiopJnJ0LCAm
ZmxfdHVubmVsLCBBRl9JTkVUKTsNCiAJCWlmIChlcnIpDQogCQkJZ290byBl
cnJvcjsNCisJCWRzdC0+ZmxhZ3MgfD0gRFNUX1hGUk1fVFVOTkVMOw0KIAl9
IGVsc2Ugew0KIAkJZHN0X2hvbGQoJnJ0LT51LmRzdCk7DQogCX0NCg==

--279739137-1600102413-1110131758=:23235--
