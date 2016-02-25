From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] ipv4: in new netns initialize sysctls in net.ipv4.conf.*
	with defaults
Date: Thu, 25 Feb 2016 15:20:48 +0100
Message-ID: <56CF0DC0.7030003@6wind.com>
References: <20160221071102.9686.63148.stgit@buzz>
	<20160223.182121.2101846699151527296.davem@davemloft.net>
	<87y4a9ix2h.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vvs-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87y4a9ix2h.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

TGUgMjQvMDIvMjAxNiAyMzowNSwgRXJpYyBXLiBCaWVkZXJtYW4gYSDDqWNyaXQgOgpbc25pcF0K
PiBJbiB0aGUgZ2VuZXJhbCBjYXNlIHRoZSBjdXJyZW50IGJlaGF2aW9yIGlzIHJhbmRvbSBhbmQg
bm90IHNvbWV0aGluZwo+IGFwcGxpY2F0aW9ucyBjYW4gY291bnQgb24sIGFuZCB3ZSB3b3VsZCBk
byB3ZWxsIHRvIGZpeCBpdCBzbyBpdCBpcyBsZXNzCj4gcmFuZG9tLiAgSW4gcGFydGljdWxhciBj
b25zaWRlciB0aGUgY2FzZSBvZiBhbiBhcHBsaWNhdGlvbiBpbiBhCj4gbm9uLWluaXRpYWwgbmV0
d29yayBuYW1lc3BhY2UgY3JlYXRpbmcgYSBuZXcgbmV0d29yayBuYW1lc3BhY2UuICBJdCBpcwo+
IG5vdCBldmVuIHBvc3NpYmxlIHRvIHByZWRpY3Qgd2hhdCB2YWx1ZXMgdGhleSB3aWxsIGdldCBm
b3Igc3lzY3Rscwo+IHRvZGF5LgorMQoKPiAgRnJvbSBhIGJhY2t3YXJkcyBjb21wYXRpYmlsaXR5
IHN0YW5kcG9pbnQgd2UgYXJlIHByb2JhYmx5IGJldHRlciBvZmYKPiB3aXRoIGNvcHlpbmcgZnJv
bSB0aGUgY3VycmVudCBuZXR3b3JrIG5hbWVzcGFjZSByYXRoZXIgdGhhbiB0aGUgaW5pdGlhbAo+
IG5ldHdvcmsgbmFtZXNwYWNlLiAgQXMgdGhhdCBtb3JlIGNsb3NlbHkgcmVzZW1ibGVzIHRoZSBj
b21tb24gY2FzZQo+IHRvZGF5LgorMQoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5s
aW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFp
bG1hbi9saXN0aW5mby9jb250YWluZXJz
