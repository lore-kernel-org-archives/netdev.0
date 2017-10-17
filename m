From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Tue, 17 Oct 2017 10:57:43 -0700
Message-ID: <1508263063.3129.35.camel@HansenPartnership.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
	<1508255091.3129.27.camel@HansenPartnership.com>
	<eb96144d-4ab5-7f9f-de18-b296db35a00a@schaufler-ca.com>
	<1982291.vr6V9CPzqu@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
	Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
To: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1982291.vr6V9CPzqu@x2>
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

T24gVHVlLCAyMDE3LTEwLTE3IGF0IDEzOjE1IC0wNDAwLCBTdGV2ZSBHcnViYiB3cm90ZToKPiBP
biBUdWVzZGF5LCBPY3RvYmVyIDE3LCAyMDE3IDEyOjQzOjE4IFBNIEVEVCBDYXNleSBTY2hhdWZs
ZXIgd3JvdGU6Cj4gPiAKPiA+ID4gCj4gPiA+IFRoZSBpZGVhIGlzIHRoYXQgcHJvY2Vzc2VzIHNw
YXduZWQgaW50byBhIGNvbnRhaW5lciB3b3VsZCBiZQo+ID4gPiBsYWJlbGxlZCBieSB0aGUgY29u
dGFpbmVyIG9yY2hlc3RyYXRpb24gc3lzdGVtLsKgwqBJdCdzIHVuY2xlYXIKPiA+ID4gd2hhdCBz
aG91bGQgaGFwcGVuIHRvIHByb2Nlc3NlcyB1c2luZyBuc2VudGVyIGFmdGVyIHRoZSBmYWN0LCBi
dXQKPiA+ID4gcG9saWN5IGZvciB0aGF0IHNob3VsZCBiZSB1cCB0byB0aGUgb3JjaGVzdHJhdGlv
biBzeXN0ZW0uCj4gPiAKPiA+IEknbSBmaW5lIHdpdGggdGhhdC4gVGhlIHVzZXIgc3BhY2UgcG9s
aWN5IGNhbiBiZSBhbnl0aGluZyB5J2FsbAo+ID4gbGlrZS4KPiAKPiBJIHRoaW5rIHRoZXJlIHNo
b3VsZCBiZSBhIGxvZ2luIGV2ZW50LgoKSSB0aG91Z2h0IHlvdSB3YW50ZWQgdGhpcyBmb3IgY29u
dGFpbmVycz8gwqBDb250YWluZXIgY3JlYXRpb24gZG9lc24ndApoYXZlIGxvZ2luIGV2ZW50cy4g
wqBJbiBhbiB1bnByaXZpbGVnZWQgb3JjaGVzdHJhdGlvbiBzeXN0ZW0gaXQgbWF5IGJlCmhhcmQg
dG8gc3ludGhldGljYWxseSBtYW51ZmFjdHVyZSB0aGVtLgoKSmFtZXMKCl9fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0
CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51
eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
