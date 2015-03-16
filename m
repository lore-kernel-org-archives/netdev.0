From: =?koi8-r?B?8MHOz9cg4c7E0sXK?= <rockford@yandex.ru>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c,
 TX is broken. In 4.0.0-rc3
Date: Mon, 16 Mar 2015 16:37:48 +0300
Message-ID: <726281426513068@web10o.yandex.ru>
References: <390621425930628@web28o.yandex.ru>
 <3625951426018334@web26j.yandex.ru>
 <BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Transfer-Encoding: base64
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

SGkhCgoxNi4wMy4yMDE1LCAxMjoyMSwgImZ1Z2FuZy5kdWFuQGZyZWVzY2FsZS5jb20iIDxmdWdh
bmcuZHVhbkBmcmVlc2NhbGUuY29tPjoKPgo+IEkgdHJ5IHlvdXIgY2FzZSBvbiBpLk1YNnEgc2Fi
cmVzZCBib2FyZCB3aXRoIG5ldCB0cmVlIGtlcm5lbC4KPiByb290QGZyZWVzY2FsZSB+JCB1bmFt
ZSAtcgo+IDQuMC4wLXJjMy0xMTA3MS1nZjAwYmJkMgo+Cj4gV2l0aCBiZWxvdyB0ZXN0IHN0ZXBz
IGZvciAxMCB0aW1lLCB0aGUgemVybyBmaWxlIHNpemUgcmFuZ2UgZnJvbSAyME0gdG8gMzAwTSBi
eXRlcywKPiBjb21wYXJlIHRoZSBtZDVzdW0gY2hlY2tzdW0gYmV0d2VlbiBpLk1YNnEgYW5kIGku
TVg2cS9QQyBob3N0LCCadGhlIGNoZWNrc3VtIGlzIHRoZSBzYW1lLgo+Cj4gcm9vdEBmcmVlc2Nh
bGUgfiQgcm0gemVyb3MKPiByb290QGZyZWVzY2FsZSB+JCBkZCBpZj0vZGV2L3plcm8gb2Y9emVy
b3MgYnM9MU0gY291bnQ9MzAwCj4gMzAwKzAgcmVjb3JkcyBpbgo+IDMwMCswIHJlY29yZHMgb3V0
Cj4gMzE0NTcyODAwIGJ5dGVzICgzMDAuME1CKSBjb3BpZWQsIDEuODExNDU5IHNlY29uZHMsIDE2
NS42TUIvcwo+IHJvb3RAZnJlZXNjYWxlIH4kIG1kNXN1bSAtYiB6ZXJvcwo+IDBkOTdhOWNkOGJi
ZDdjZTc1YTJhNzZiYjA2MjU4OTE1IJp6ZXJvcwo+IHJvb3RAZnJlZXNjYWxlIH4kIGNwIHplcm9z
IC9tbnQvbmZzLyAtZgo+IHJvb3RAZnJlZXNjYWxlIH4kIHJtIHplcm9zCj4gcm9vdEBmcmVlc2Nh
bGUgfiQgY3AgL21udC9uZnMvemVyb3MgLi8KPiByb290QGZyZWVzY2FsZSB+JCBtZDVzdW0gLWIg
emVyb3MKPiAwZDk3YTljZDhiYmQ3Y2U3NWEyYTc2YmIwNjI1ODkxNSCaemVyb3MKPgo+IERvIHlv
dSBoYXZlIGFueSBsb3N0IGZvciByZXByb2R1Y2UgdGhlIGlzc3VlID8KCkN1cnJlbnQgbmV0IHRy
ZWUgZG9lcyBub3QgaGF2ZSB0aGlzIGlzc3VlLCBpdCB3b3JrcyBmaW5lLiBUaGFua3MgdG8gYWxs
LgoKRnJvbSBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvZGF2
ZW0vbmV0LmdpdAoKYXB4QGFzdHJhOn4kIHVuYW1lIC1yCjQuMC4wLXJjMy0wMDE1MC1nMTA2NDBk
My1kaXJ0eQoKCi0tCiDhzsTSxcoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCmxpbnV4LWFybS1rZXJuZWwgbWFpbGluZyBsaXN0CmxpbnV4LWFybS1rZXJu
ZWxAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFu
L2xpc3RpbmZvL2xpbnV4LWFybS1rZXJuZWwK
