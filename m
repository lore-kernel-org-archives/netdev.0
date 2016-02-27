From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: Re: [PATCH 3/4] net: ipv4: tcp_probe: Replace timespec with
	timespec64
Date: Sat, 27 Feb 2016 08:26:05 +0530
Message-ID: <CABeXuvpuSCQx9JQbJLpR1cCKAFZc5L5ta-rrf2X=WhCy46kt7w@mail.gmail.com>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
 <1456384031-29244-4-git-send-email-deepa.kernel@gmail.com>
 <10756653.OfUfst5I70@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org,
 Linux Network Devel Mailing List <netdev@vger.kernel.org>,
 James Morris <jmorris@namei.org>, Patrick McHardy <kaber@trash.net>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <10756653.OfUfst5I70@wuerfel>
List-Unsubscribe: <https://lists.linaro.org/mailman/options/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=unsubscribe>
List-Archive: <http://lists.linaro.org/pipermail/y2038/>
List-Post: <mailto:y2038@lists.linaro.org>
List-Help: <mailto:y2038-request@lists.linaro.org?subject=help>
List-Subscribe: <https://lists.linaro.org/mailman/listinfo/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=subscribe>
Errors-To: y2038-bounces@lists.linaro.org
Sender: "Y2038" <y2038-bounces@lists.linaro.org>
List-Id: netdev.vger.kernel.org

T24gVGh1LCBGZWIgMjUsIDIwMTYgYXQgODozMSBQTSwgQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5k
Yi5kZT4gd3JvdGU6Cj4gT24gV2VkbmVzZGF5IDI0IEZlYnJ1YXJ5IDIwMTYgMjM6MDc6MTAgRGVl
cGEgRGluYW1hbmkgd3JvdGU6Cj4+IFRDUCBwcm9iZSBsb2cgdGltZXN0YW1wcyB1c2Ugc3RydWN0
IHRpbWVzcGVjIHdoaWNoIGlzCj4+IG5vdCB5MjAzOCBzYWZlLiBFdmVuIHRob3VnaCB0aW1lc3Bl
YyBtaWdodCBiZSBnb29kIGVub3VnaCBoZXJlCj4+IGFzIGl0IGlzIHVzZWQgdG8gcmVwcmVzZW50
IGRlbHRhIHRpbWUsIHRoZSBwbGFuIGlzIHRvIGdldCByaWQKPj4gb2YgYWxsIHVzZXMgb2YgdGlt
ZXNwZWMgaW4gdGhlIGtlcm5lbC4KPj4gUmVwbGFjZSB3aXRoIHN0cnVjdCB0aW1lc3BlYzY0IHdo
aWNoIGlzIHkyMDM4IHNhZmUuCj4+Cj4+IFByaW50cyBzdGlsbCB1c2UgdW5zaWduZWQgbG9uZyBm
b3JtYXQgYW5kIHR5cGUuCj4+IFRoaXMgaXMgYmVjYXVzZSBsb25nIGlzIDY0IGJpdCBvbiA2NCBi
aXQgc3lzdGVtcyBhbmQgMzIgYml0IG9uCj4+IDMyIGJpdCBzeXN0ZW1zLiBIZW5jZSwgdGltZTY0
X3QoNjQgYml0IHNpZ25lZCBudW1iZXIpIGRvZXMgbm90Cj4+IGhhdmUgYSBzcGVjaWZpZXIgdGhh
dCBtYXRjaGVzIG9uIGJvdGggYXJjaGl0ZWN0dXJlcy4KPgo+IEFjdHVhbGx5IHRpbWU2NF90IGlz
IGFsd2F5cyAnbG9uZyBsb25nJywgYnV0IHR2X3NlYyBpcyB0aW1lX3QKPiAobG9uZykgaW5zdGVh
ZCBvZiB0aW1lNjRfdCBvbiA2NC1iaXQgYXJjaGl0ZWN0dXJlcy4KPgo+IFVzaW5nIGEgJWxsIGZv
cm1hdCBzdHJpbmcgYW5kIGEgY2FzdCB0byBzNjQgd291bGQgd29yayBhcyB3ZWxsLAo+IGJ1dCBh
cyB5b3Ugc2F5IGFib3ZlLCBpdCdzIG5vdCBpbXBvcnRhbnQgaGVyZS4KCllvdSBhcmUgcmlnaHQu
IEEgY2FzdCB0byB1NjQgd291bGQgd29yayBhcyB3ZWxsLgpJIG1pc3NlZCB0aGF0IHRoZSBzaXpl
IG9mIGxvbmcgbG9uZyBvbiA2NCBiaXQgYXJjaGl0ZWN0dXJlcyBhY2NvcmRpbmcKdG8gYWxsIGN1
cnJlbnQKZGF0YSBtb2RlbHMgaXMgZXF1aXZhbGVudCB0byBsb25nLgoKSSB3aWxsIGxlYXZlIHRo
ZSBwcmludHMgdG8gYmUgaW4gbG9uZyBmb3JtYXQuCkJ1dCwgd2lsbCByZXdvcmQgdGhlIGNvbW1p
dCB0ZXh0IGluIHYyLgoKVGhhbmtzLAotRGVlcGEKX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KWTIwMzggbWFpbGluZyBsaXN0ClkyMDM4QGxpc3RzLmxpbmFy
by5vcmcKaHR0cHM6Ly9saXN0cy5saW5hcm8ub3JnL21haWxtYW4vbGlzdGluZm8veTIwMzgK
