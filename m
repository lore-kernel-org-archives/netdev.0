From: =?UTF-8?B?SsOpcsOpbXk=?= Lefaure <jeremy.lefaure@lse.epita.fr>
Subject: Re: [PATCH 00/18] use ARRAY_SIZE macro
Date: Mon, 2 Oct 2017 21:33:12 -0400
Message-ID: <20171002213312.3f904290@blatinox-laptop.localdomain>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
 <20171001220131.GA11812@eros>
 <20171001205220.10b78086@blatinox-laptop.localdomain>
 <20171002053554.GA28743@kroah.com>
 <20171002192224.GD1903@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: alsa-devel@alsa-project.org, nouveau@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, dm-devel@redhat.com,
 brcm80211-dev-list@cypress.com, devel@driverdev.osuosl.org,
 linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
 amd-gfx@lists.freedesktop.org,
 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-acpi@vger.kernel.org,
 linux-video@atrey.karlin.mff.cuni.cz, intel-wired-lan@lists.osuosl.org,
 Greg KH <greg@kroah.com>, linux-media@vger.kernel.org,
 intel-gfx@lists.freedesktop.org, ecryptfs@vger.kernel.org,
 brcm80211-dev-list.pdl@broadcom.com, linux-raid@vger.kernel.org,
 openipmi-developer@lists.sourceforge.net, intel-gvt-dev@lists.freedesktop.org,
 devel@acpica.org, linux-nfs@vger.kernel.org, jlayton@redhat.com,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-integrity@vger.kernel.org, "
To: bfields@fieldses.org (J. Bruce Fields)
Return-path: <openipmi-developer-bounces@lists.sourceforge.net>
In-Reply-To: <20171002192224.GD1903@fieldses.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/openipmi-developer>,
 <mailto:openipmi-developer-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=openipmi-developer>
List-Post: <mailto:openipmi-developer@lists.sourceforge.net>
List-Help: <mailto:openipmi-developer-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/openipmi-developer>,
 <mailto:openipmi-developer-request@lists.sourceforge.net?subject=subscribe>
Errors-To: openipmi-developer-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

T24gTW9uLCAyIE9jdCAyMDE3IDE1OjIyOjI0IC0wNDAwCmJmaWVsZHNAZmllbGRzZXMub3JnIChK
LiBCcnVjZSBGaWVsZHMpIHdyb3RlOgoKPiBNYWlubHkgSSdkIGp1c3QgbGlrZSB0byBrbm93IHdo
aWNoIHlvdSdyZSBhc2tpbmcgZm9yLiAgRG8geW91IHdhbnQgbWUgdG8KPiBhcHBseSB0aGlzLCBv
ciB0byBBQ0sgaXQgc28gc29tZW9uZSBlbHNlIGNhbj8gIElmIGl0J3Mgc2VudCBhcyBhIHNlcmll
cwo+IEkgdGVuZCB0byBhc3N1bWUgdGhlIGxhdHRlci4KPiAKPiBCdXQgaW4gdGhpcyBjYXNlIEkn
bSBhc3N1bWluZyBpdCdzIHRoZSBmb3JtZXIsIHNvIEknbGwgcGljayB1cCB0aGUgbmZzZAo+IG9u
ZS4uLi4KQ291bGQgeW91IHRvIGFwcGx5IHRoZSBORlNEIHBhdGNoICgibmZzZDogdXNlIEFSUkFZ
X1NJWkUiKSB3aXRoIHRoZQpSZXZpZXdlZC1ieTogSmVmZiBMYXl0b24gPGpsYXl0b25AcmVkaGF0
LmNvbT4pIHRhZyBwbGVhc2UgPwoKVGhpcyBwYXRjaCBpcyBhbiBpbmRpdmlkdWFsIHBhdGNoIGFu
ZCBpdCBzaG91bGQgbm90IGhhdmUgYmVlbiBzZW50IGluIGEKc2VyaWVzIChzb3JyeSBhYm91dCB0
aGF0KS4KClRoYW5rIHlvdSwKSsOpcsOpbXkKCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpDaGVjayBv
dXQgdGhlIHZpYnJhbnQgdGVjaCBjb21tdW5pdHkgb24gb25lIG9mIHRoZSB3b3JsZCdzIG1vc3QK
ZW5nYWdpbmcgdGVjaCBzaXRlcywgU2xhc2hkb3Qub3JnISBodHRwOi8vc2RtLmxpbmsvc2xhc2hk
b3QKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KT3Blbmlw
bWktZGV2ZWxvcGVyIG1haWxpbmcgbGlzdApPcGVuaXBtaS1kZXZlbG9wZXJAbGlzdHMuc291cmNl
Zm9yZ2UubmV0Cmh0dHBzOi8vbGlzdHMuc291cmNlZm9yZ2UubmV0L2xpc3RzL2xpc3RpbmZvL29w
ZW5pcG1pLWRldmVsb3Blcgo=
