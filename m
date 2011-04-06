From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: [PATCH 00/34] Make kernel build deterministic
Date: Wed, 06 Apr 2011 12:25:28 +0300
Message-ID: <1302081928.2742.40.camel@localhost>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
	<20110405154918.GA31337@suse.de> <1302031447.2608.41.camel@koala>
	<4D9C2D56.70700@suse.cz>
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
	tipc-discussion@lists.sourceforge.net, dwmw2@infradead.org,
	linux-media@vger.kernel.org, arnaud.giersch@free.fr,
	linux-kbuild@vger.kernel.org, IvDoorn@gmail.com,
	teigland@redhat.com, tony.olech@elandigitalsystems.com,
	apw@canonical.com, linux-hams@vger.kernel.org,
	tglx@linutronix.de, swhiteho@redhat.com,
	linux-arm-kernel@lists.infradead.org, linux-edac@vger.kernel.org,
	jon.maloy@ericsson.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, Greg KH <gregkh@suse.de>,
	linux-wireless@vger.kernel.org, linux-kernel@
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4D9C2D56.70700@suse.cz>
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

T24gV2VkLCAyMDExLTA0LTA2IGF0IDExOjA3ICswMjAwLCBNaWNoYWwgTWFyZWsgd3JvdGU6Cj4g
PiBTbyBhZGRpdGlvbmFsbHksIEknZCBzdWdnZXN0Ogo+ID4gMS4gSW5zdHJ1bWVudCBjaGVja3Bh
dGNoLnBsIGFuZCBtYWtlIGl0IGVyciBvciB3YXJuIG9uIHRpbWVzdGFtcHMuCj4gCj4gVGhpcyBp
cyBwYXRjaCAzNC8zNCBpbiB0aGlzIHNlcmllczogaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTEv
NC81LzE5OAoKWWVhaCwgZ3JlYXQsIGRpZCBub3Qgbm90aWNlLCB0aGFua3MhCgo+ID4gMi4gUHJv
YmFibHkgaW5zdHJ1bWVudCBsaW51eC1uZXh0IHRvIHJpc2UgYSB3YXJuaW5nIHdoZW4gcGVvcGxl
IGJyZWFrCj4gPiAgICB0aGlzLgo+IAo+IEknbSBub3Qgc3VyZSBpZiBTdGVwaGVuIGhhcyB0aGF0
IG11Y2ggc3BhcmUgdGltZSwgYW5kIEkgZG9uJ3QgdGhpbmsgaXQKPiBpcyBuZWNlc3NhcnkuIEkg
dGhpbmsgdGhlIGNoZWNrcGF0Y2ggY2hlY2sgaXMgc3VmZmljaWVudCBhbmQgSSdsbCBjaGVjawo+
IG15c2VsZiBvY2Nhc2lvbmFsbHkuCgpZZXMsIHRoYXQncyBmaW5lLCBJIGp1c3Qgd2FudGVkIHRv
IHNwZWFrIHRoaXMgb3V0IC0gdGhlcmUgaXMgYQpwcm9iYWJpbGl0eSB0aGF0IHNvbWVvbmUgZ2V0
cyBleGNpdGVkIGFuZCBjcmVhdGVzIHNvbWUgaW5zdHJ1bWVudGF0aW9uCnRvIGtidWlsZCB0byBh
dXRvbWF0aWNhbGx5IGRldGVjdCBiYWQgdGhpbmdzIGFuZCB0aGVuIFN0ZXBoZW4gY291bGQKZWFz
aWx5IHVzZSB0aGF0LgoKV1JUICJub3QgbmVjZXNzYXJ5IiAtIHdlbGwsIEkgdGhpbmsgaXQgaXMg
YWx3YXlzIGJldHRlciB0byBjdXQgYmFkCnRoaW5ncyBiZWZvcmUgdGhleSBhcmUgbWVyZ2VkLCBy
YXRoZXIgdGhhbiBhZnRlcndhcmRzLgoKQnV0IGFueXdheSwgbGV0J3MgZm9yZ2V0IGFib3V0IHRo
aXMuCgotLSAKQmVzdCBSZWdhcmRzLApBcnRlbSBCaXR5dXRza2l5ICjQkNGA0YLRkdC8INCR0LjR
gtGO0YbQutC40LkpCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJtLWtlcm5lbEBsaXN0
cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxtYW4vbGlzdGlu
Zm8vbGludXgtYXJtLWtlcm5lbAo=
