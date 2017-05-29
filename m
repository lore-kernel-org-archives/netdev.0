From: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Mon, 29 May 2017 15:58:33 +0000
Message-ID: <AM4PR0501MB1940D05A19F098286B99EAD0DBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170526030701.du4345mbprhcwjyi@ast-mbp>
 <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA@mail.gmail.com>
 <20170526175624.5xxflpf24je5673h@ast-mbp>
 <20170526181517.GA3860@obsidianresearch.com>
 <AM4PR0501MB1940330F0EBAA819C87C5278DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529153131.GB7924@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Doug Ledford" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jsorensen-b10kYP2dOMg@public.gmane.org" <jsorensen-b10kYP2dOMg@public.gmane.org>,
        "Andy Shevchenko" <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alan Tull <atull-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>,
        "yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170529153131.GB7924-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBKYXNvbiBHdW50aG9ycGUgW21h
aWx0bzpqZ3VudGhvcnBlQG9ic2lkaWFucmVzZWFyY2guY29tXQ0KPiBTdWJqZWN0OiBSZTogW2Zv
ci1uZXh0IDQvNl0gbmV0L21seDU6IEZQR0EsIEFkZCBiYXNpYyBzdXBwb3J0IGZvciBJbm5vdmEN
Cj4gDQo+IE9uIFN1biwgTWF5IDI4LCAyMDE3IGF0IDA3OjIyOjI3QU0gKzAwMDAsIElsYW4gVGF5
YXJpIHdyb3RlOg0KPiANCj4gPiBUaGlzIGlzIG5laXRoZXIgUENJLWJhciBtYXBwZWQsIG5vciBt
YWlsYm94IGNvbW1hbmQuDQo+ID4gVGhlIEZQR0EgaXMgaW5kZWVkIGEgYnVtcC1vbi10aGUtd2ly
ZS4NCj4gPiAoSXQgaGFzIEkyQyB0byB0aGUgQ1g0IGNoaXAsIGJ1dCB0aGF0IGlzIGZvciBkZWJ1
ZyBwdXJwb3NlcywgYW5kIHRvbw0KPiBzbG93DQo+ID4gdG8gcGVyZm9ybSByZWFsIHByb2dyYW1t
aW5nKQ0KPiANCj4gV2FpdC4uIFNvIGlmIGl0IHRydWVseSBoYXMgbm90aGluZyB0byBkbyB3aXRo
IHRoZSBleGlzdGluZyBtZWxsYW5veA0KPiBkcml2ZXIsIHRoZW4gbm90aGluZyBtb3JlIHRoYW4g
dGhlIGZwZ2EgbG9hZGVyIHNob3VsZCBiZSBpbiB0aGUgbWx4NQ0KPiBkaXJlY3Rvcnk/DQoNClRy
dWUsIGV4Y2VwdCBpbiBzcGVjaWZpYyBjYXNlcyB3aGVuIHRoZSBGUEdBIG1heSBtYW5nbGUgdGhl
IHBhY2tldHMgaW4NCmEgd2F5IHRoYXQgdGhlIG5ldGRldmljZSBjb25maWd1cmVzLCBhbmQgdGhl
IGRyaXZlciBuZWVkcyB0byBhZGFwdCB0aGUNCmRhdGEgcGF0aC4NCg0KU3VjaCBpcyB0aGUgY2Fz
ZSBvZiBJUFNlYyBhbmQgVExTIG9mZmxvYWRzLg0KVGhvc2UgYXJlIHRpZWQgdG8gdGhlIG1seDUg
RXRoZXJuZXQgZHJpdmVyIChpc29sYXRlZCB3aXRoIGEga2NvbmZpZykuDQoNCj4gDQo+ID4gT25l
IGZsYXZvciBvZiB0aGUgcHJvZHVjdCwgdGhlIElubm92YSBGbGV4LCBhbGxvd3MgY3VzdG9tZXIg
bG9naWMgaW4gdGhlDQo+ID4gRlBHQS4gQnV0IGV2ZW4gdGhlbiBpdCBpcyAid3JhcHBlZCIgYnkg
TWVsbGFub3ggc2hlbGwgbG9naWMuDQo+ID4gV2UgcGxhbiB0byBoYXZlIGFuIGluLWtlcm5lbCBB
UEkgZm9yIHdyaXRpbmcgY2xpZW50IGRyaXZlcnMgZm9yIElubm92YQ0KPiA+IEZsZXguDQo+IA0K
PiBUaGUgRlBHQSBzdWJzeXN0ZW0gYWxyZWFkeSBoYXMgQVBJcyBmb3IgcGFydGlhbCByZWNvbmZp
Z3VyYXRpb24gdXNlDQo+IGNhc2VzLCB5b3UgcHJvYmFibHkgc2hvdWxkIG5vdCByZS1pbnZlbnQg
dGhhdCB1bmRlciB0aGUgbWx4NSBkcml2ZXIuDQoNCldoZW4gdGhlIHRpbWUgY29tZXMgdG8gaW50
cm9kdWNlIHRoZSBBUEkgZm9yIHRoYXQsIHdlIHdpbGwgaW52ZXN0aWdhdGUgYWxsDQpPcHRpb25z
IGF2YWlsYWJsZS4gQ3VycmVudGx5IHRoaXMgaXMgbm90IGluIHRoZSBwbGFucyBmb3IgTGludXgu
DQoNCihXZSBkbyBoYXZlIGFuIG91dC1vZi10cmVlICdoYWNrJyBkcml2ZXIgZm9yIHRoaXMsIGJ1
dCBpdCdzIHBsYW5uZWQgdG8gYmUNCnJlcGxhY2VkIHdpdGggc29tZXRoaW5nIG1vcmUgYXBwcm9w
cmlhdGUgbGF0ZXIgb24pDQoNCj4gDQo+IEphc29uDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
