From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: [PATCH 00/34] Make kernel build deterministic
Date: Tue, 05 Apr 2011 22:24:07 +0300
Message-ID: <1302031447.2608.41.camel@koala>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
	<20110405154918.GA31337@suse.de>
Reply-To: dedekind1@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: anil_ravindranath@pmc-sierra.com, mchehab@redhat.com,
	benh@kernel.crashing.org, mac@melware.de, aacraid@adaptec.com,
	linux-mtd@lists.infradead.org, allan.stephens@windriver.com,
	hpa@zytor.com, t.sailer@alumni.ethz.ch, gwingerde@gmail.com,
	x86@kernel.org, elf@buici.com, cluster-devel@redhat.com,
	ccaulfie@redhat.com, mingo@redhat.com, dougthompson@xmission.com,
	dwmw2@infradead.org, linux-media@vger.kernel.org,
	jon.maloy@ericsson.com, arnaud.giersch@free.fr,
	linux-kbuild@vger.kernel.org, IvDoorn@gmail.com,
	teigland@redhat.com, tony.olech@elandigitalsystems.com,
	apw@canonical.com, linux-hams@vger.kernel.org,
	tglx@linutronix.de, swhiteho@redhat.com,
	linux-arm-kernel@lists.infradead.org, linux-edac@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.ke
To: Greg KH <gregkh@suse.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20110405154918.GA31337@suse.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDExLTA0LTA1IGF0IDA4OjQ5IC0wNzAwLCBHcmVnIEtIIHdyb3RlOgo+IE9uIFR1
ZSwgQXByIDA1LCAyMDExIGF0IDA0OjU4OjQ3UE0gKzAyMDAsIE1pY2hhbCBNYXJlayB3cm90ZToK
PiA+IAo+ID4gSGksCj4gPiAKPiA+IHRoaXMgc2VyaWVzIG1ha2VzIGl0IHBvc3NpYmxlIHRvIGJ1
aWxkIGJpdC1pZGVudGljYWwga2VybmVsIGltYWdlIGFuZAo+ID4gbW9kdWxlcyBmcm9tIGlkZW50
aWNhbCBzb3VyY2VzLiBPZiBjb3Vyc2UgdGhlIGJ1aWxkIGlzIGFscmVhZHkKPiA+IGRldGVybWlu
aXN0aWMgaW4gdGVybXMgb2YgYmVoYXZpb3Igb2YgdGhlIGNvZGUsIGJ1dCB0aGUgdmFyaW91cwo+
ID4gdGltZXN0YW1wcyBlbWJlZGRlZCBpbiB0aGUgb2JqZWN0IGZpbGVzIG1ha2UgaXQgaGFyZCB0
byBjb21wYXJlIHR3bwo+ID4gYnVpbGRzLCBmb3IgaW5zdGFuY2UgdG8gdmVyaWZ5IHRoYXQgYSBt
YWtlZmlsZSBjbGVhbnVwIGRpZG4ndAo+ID4gYWNjaWRlbnRhbGx5IGNoYW5nZSBzb21ldGhpbmcu
IEEgcHJpbWUgZXhhbXBsZSBpcyAvcHJvYy9jb25maWcuZ3osIHdoaWNoCj4gPiBoYXMgYm90aCBh
IHRpbWVzdGFtcCBpbiB0aGUgZ3ppcCBoZWFkZXIgYW5kIGEgdGltZXN0YW1wIGluIHRoZSBwYXls
b2FkCj4gPiBkYXRhLiBXaXRoIHRoaXMgc2VyaWVzIGFwcGxpZWQsIGEgc2NyaXB0IGxpa2UgdGhp
cyB3aWxsIHByb2R1Y2UKPiA+IGlkZW50aWNhbCBrZXJuZWxzIGVhY2ggdGltZToKPiAKPiBWZXJ5
IG5pY2Ugc3R1ZmYuICBEbyB5b3Ugd2FudCB0byB0YWtlIHRoZSBpbmRpdmlkdWFsIHBhdGNoZXMg
dGhyb3VnaCBvbmUKPiBvZiB5b3VyIHRyZWVzLCBvciBkbyB5b3UgbWluZCBpZiB0aGUgc3Vic3lz
dGVtIG1haW50YWluZXJzIHRha2UgdGhlbQo+IHRocm91Z2ggdGhlaXJzPwoKQnV0IHVuZm9ydHVu
YXRlbHksIGl0IGlzIHZlcnkgZWFzeSB0byBicmVhayB0aGlzIGFuZCBmb3Igc3VyZSBpdCdsbCBi
ZQpicm9rZW4gdmVyeSBzb29uLgoKU28gYWRkaXRpb25hbGx5LCBJJ2Qgc3VnZ2VzdDoKMS4gSW5z
dHJ1bWVudCBjaGVja3BhdGNoLnBsIGFuZCBtYWtlIGl0IGVyciBvciB3YXJuIG9uIHRpbWVzdGFt
cHMuCjIuIFByb2JhYmx5IGluc3RydW1lbnQgbGludXgtbmV4dCB0byByaXNlIGEgd2FybmluZyB3
aGVuIHBlb3BsZSBicmVhawogICB0aGlzLgoKLS0gCkJlc3QgUmVnYXJkcywKQXJ0ZW0gQml0eXV0
c2tpeSAo0JHQuNGC0Y7RhtC60LjQuSDQkNGA0YLRkdC8KQoKCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCmxpbnV4LWFybS1rZXJuZWwgbWFpbGluZyBsaXN0
CmxpbnV4LWFybS1rZXJuZWxAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFk
ZWFkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xpbnV4LWFybS1rZXJuZWwK
