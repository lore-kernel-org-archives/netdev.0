From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
	inetpeer
Date: Fri, 08 Jun 2012 09:44:04 +0800
Message-ID: <4FD158E4.1080701@cn.fujitsu.com>
References: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20120606.104323.1698446129331745479.davem@davemloft.net>
	<20120607.144301.1259354794384347085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120607.144301.1259354794384347085.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

5LqOIDIwMTLlubQwNuaciDA45pelIDA1OjQzLCBEYXZpZCBNaWxsZXIg5YaZ6YGTOgo+IEZyb206
IERhdmlkIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4KPiBEYXRlOiBXZWQsIDA2IEp1biAy
MDEyIDEwOjQzOjIzIC0wNzAwIChQRFQpCj4gCj4+IFNvIEknbSBkcm9wcGluZyB0aGVzZSB0d28g
cGF0Y2hlcyBhbmQgd2lsbCB3b3JrIG9uIHRoZSBtZW50aW9uZWQKPj4gYXBwcm9hY2ggdG8gdGhp
cyBmaXguCj4gCj4gSXQgdHVybnMgb3V0IHRoYXQgZXZlbiBpZiBJIG1vdmUgdGhlIGluZXRwZWVy
IHJvb3RzIGludG8gdGhlIEZJQiBydWxlcwo+IGxheWVyLCB3ZSBzdGlsbCBuZWVkIHlvdXIgY2hh
bmdlcyBHYW8uCj4gCj4gQnV0IHlvdXIgcGF0Y2hlcyBhcmUgY29ycnVwdGVkLiAgRm9yIGV4YW1w
bGUsIGluIHRoaXMgcGF0Y2gsCj4gdGhlIGZpbmFsIGh1bmsgZm9yIG5ldC9pcHY0L2luZXRwZWVy
LmMgaGFzIG5vIGRpZmZlcmVuY2VzIG9ubHkKPiBjb250ZXh0LiAgVGhhdCdzIGFuIGV4dHJlbWVs
eSBjb3JydXB0ZWQgcGF0Y2guCgpTb3JyeSBmb3IgbXkgcG9vbCBlbmdsaXNoLCBJIGRvbid0IHVu
ZGVyc3RhbmQgdGhpcy4KQ2FuIHlvdSBleHBsYWluIGl0IGZvciBtZT8KCj4gCj4gUGxlYXNlIHJl
c29sdmUgdGhpcywgYW5kIGFkZCB0aGUgTlVMTCBwb2ludGVyIHNldHRpbmdzIGR1cmluZyBuZXR3
b3JrCj4gbmFtZXNwYWNlIHNodXRkb3duIHRoYXQgRXJpYyBEdW1hemV0IGFza2VkIGZvci4KCk9L
LCBJIHdpbGwgZG8gaXQuClRoYW5rcy4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5s
aW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFp
bG1hbi9saXN0aW5mby9jb250YWluZXJz
