From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Wed, 24 Sep 2014 11:31:55 +0200
Message-ID: <54228F8B.2030804@6wind.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
	<CALCETrWnZtWstBviDxcHpLpjHF3R+sgS48RYf2pbKBYeExZVOQ@mail.gmail.com>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrWnZtWstBviDxcHpLpjHF3R+sgS48RYf2pbKBYeExZVOQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

TGUgMjMvMDkvMjAxNCAyMToyNiwgQW5keSBMdXRvbWlyc2tpIGEgw6ljcml0IDoKPiBPbiBUdWUs
IFNlcCAyMywgMjAxNCBhdCA2OjIwIEFNLCBOaWNvbGFzIERpY2h0ZWwKPiA8bmljb2xhcy5kaWNo
dGVsQDZ3aW5kLmNvbT4gd3JvdGU6Cj4+IFRoZSBnb2FsIG9mIHRoaXMgc2VyaWUgaXMgdG8gYmUg
YWJsZSB0byBtdWx0aWNhc3QgbmV0bGluayBtZXNzYWdlcyB3aXRoIGFuCj4+IGF0dHJpYnV0ZSB0
aGF0IGlkZW50aWZ5IGEgcGVlciBuZXRucy4KPj4gVGhpcyBpcyBuZWVkZWQgYnkgdGhlIHVzZXJs
YW5kIHRvIGludGVycHJldCBzb21lIGluZm9ybWF0aW9ucyBjb250YWluZWQgaW4KPj4gbmV0bGlu
ayBtZXNzYWdlcyAobGlrZSBJRkxBX0xJTksgdmFsdWUsIGJ1dCBhbHNvIHNvbWUgb3RoZXIgYXR0
cmlidXRlcyBpbiBjYXNlCj4+IG9mIHgtbmV0bnMgbmV0ZGV2aWNlIChzZWUgYWxzbwo+PiBodHRw
Oi8vdGhyZWFkLmdtYW5lLm9yZy9nbWFuZS5saW51eC5uZXR3b3JrLzMxNTkzMy9mb2N1cz0zMTYw
NjQgYW5kCj4+IGh0dHA6Ly90aHJlYWQuZ21hbmUub3JnL2dtYW5lLmxpbnV4Lmtlcm5lbC5jb250
YWluZXJzLzI4MzAxL2ZvY3VzPTQyMzkpKS4KPj4KPj4gSWRzIGFyZSBzdG9yZWQgaW4gdGhlIHBh
cmVudCB1c2VyIG5hbWVzcGFjZS4gVGhlc2UgaWRzIGFyZSB2YWxpZCBvbmx5IGluc2lkZQo+PiB0
aGlzIHVzZXIgbmFtZXNwYWNlLiBUaGUgdXNlciBjYW4gcmV0cmlldmUgdGhlc2UgaWRzIHZpYSBh
IG5ldyBuZXRsaW5rIG1lc3NhZ2VzLAo+PiBidXQgb25seSBpZiBwZWVyIG5ldG5zIGFyZSBpbiB0
aGUgc2FtZSB1c2VyIG5hbWVzcGFjZS4KPgo+IFdoYXQgYWJvdXQgdGhlIHBhcmVudCAvIGFuY2Vz
dG9ycyBvZiB0aGUgb3duaW5nIHVzZXJucz8gIENhbiBwcm9jZXNzZXMKPiBpbiB0aG9zZSB1c2Vy
bnNlcyBzZWUgYW55IGZvcm0gb2YgbmV0bnMgaWQ/CldpdGggdGhpcyBzZXJpZSBuby4gSSdtIG5v
dCBzdXJlIGlmIGFuY2VzdG9ycyByZWFsbHkgbmVlZHMgdG8gYmUgYWJsZSB0bwpnZXQgdGhlc2Ug
aWRzLiBXaGF0IGlzIHlvdXIgb3Bpbmlvbj8KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0
cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcv
bWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
