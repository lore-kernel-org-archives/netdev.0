From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
	inetpeer
Date: Fri, 08 Jun 2012 13:27:18 +0800
Message-ID: <4FD18D36.3090101@cn.fujitsu.com>
References: <20120606.104323.1698446129331745479.davem@davemloft.net>
	<20120607.144301.1259354794384347085.davem@davemloft.net>
	<4FD158E4.1080701@cn.fujitsu.com>
	<20120607.205348.913373847915721607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120607.205348.913373847915721607.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

5LqOIDIwMTLlubQwNuaciDA45pelIDExOjUzLCBEYXZpZCBNaWxsZXIg5YaZ6YGTOgo+IEZyb206
IEdhbyBmZW5nIDxnYW9mZW5nQGNuLmZ1aml0c3UuY29tPgo+IERhdGU6IEZyaSwgMDggSnVuIDIw
MTIgMDk6NDQ6MDQgKzA4MDAKPiAKPj4gU29ycnkgZm9yIG15IHBvb2wgZW5nbGlzaCwgSSBkb24n
dCB1bmRlcnN0YW5kIHRoaXMuCj4+IENhbiB5b3UgZXhwbGFpbiBpdCBmb3IgbWU/Cj4gCj4gTG9v
ayBhdCB0aGUgZW5kIG9mIHRoZSBwYXJ0cyBvZiB0aGUgcGF0Y2ggdGhhdCBjaGFuZ2UKPiBuZXQv
aXB2NC9pbmV0cGVlci5jOgo+IAo+IEBAIC01ODYsMyArNjE3LDMgQEAgIG91dDoKPiAgCXdyaXRl
X3NlcXVubG9ja19iaCgmYmFzZS0+bG9jayk7Cj4gIH0KPiAgRVhQT1JUX1NZTUJPTChpbmV0cGVl
cl9pbnZhbGlkYXRlX3RyZWUpOwo+IAo+IFRoYXQgbWFrZXMgbm8gc2Vuc2UsIGl0J3MgYSBwYXRj
aCBodW5rIHdpdGggbm8gIisiIG9yICItIgo+IGxpbmVzLgoKClRoYW5rcyBEYXZpZCxnb3QgaXQu
Cgo+IAo+IFlvdXIgcGF0Y2ggd2FzIGNvcnJ1cHRlZCBieSBzb21ldGhpbmcuCj4gCj4gVGhpcyBp
cyBleHRyZW1lbHkgaXJyaXRhdGluZy4gIEkgd291bGQgcmVjb21tZW5kIHRoYXQgeW91IGVtYWls
Cj4gcGF0Y2hlcyB0byB5b3Vyc2VsZiwgYW5kIHRyeSB0byBhcHBseSB0aGUgY29waWVzIHlvdSBy
ZWNlaXZlCj4gaW4gdGhvc2UgZW1haWxzLiAgQmVjYXVzZSB0aGF0J3Mgd2hhdCB0aGUgcGVvcGxl
IHRyeWluZyB0byB1c2UKPiB5b3VyIHBhdGNoIGFyZSBnb2luZyB0byBkby4KPiAKClNvcnJ5LCBJ
IHdpbGwgdHJ5IGl0IG15c2VsZiBuZXh0IHRpbWUuIDspCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5l
cnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRp
b24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
