From: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Mon, 29 May 2017 16:09:06 +0000
Message-ID: <AM4PR0501MB19409139227E11A4A7F82F0FDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170526030701.du4345mbprhcwjyi@ast-mbp>
 <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA@mail.gmail.com>
 <20170526175624.5xxflpf24je5673h@ast-mbp>
 <20170526181517.GA3860@obsidianresearch.com>
 <AM4PR0501MB1940330F0EBAA819C87C5278DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529153131.GB7924@obsidianresearch.com>
 <AM4PR0501MB1940D05A19F098286B99EAD0DBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529160252.GA27550@obsidianresearch.com>
 <AM4PR0501MB194037FF8F17466BC9ECC73DDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
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
To: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AM4PR0501MB194037FF8F17466BC9ECC73DDBF30-dp/nxUn679gfNUYDR5dMTsDSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogbmV0ZGV2LW93bmVyQHZn
ZXIua2VybmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddDQo+IA0K
PiA+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4gRnJvbTogSmFzb24gR3VudGhvcnBl
IFttYWlsdG86amd1bnRob3JwZUBvYnNpZGlhbnJlc2VhcmNoLmNvbV0NCj4gPiBTdWJqZWN0OiBS
ZTogW2Zvci1uZXh0IDQvNl0gbmV0L21seDU6IEZQR0EsIEFkZCBiYXNpYyBzdXBwb3J0IGZvciBJ
bm5vdmENCj4gPg0KPiA+IE9uIE1vbiwgTWF5IDI5LCAyMDE3IGF0IDAzOjU4OjMzUE0gKzAwMDAs
IElsYW4gVGF5YXJpIHdyb3RlOg0KPiA+ID4gPiBGcm9tOiBKYXNvbiBHdW50aG9ycGUgW21haWx0
bzpqZ3VudGhvcnBlQG9ic2lkaWFucmVzZWFyY2guY29tXQ0KPiA+ID4gPiBTdWJqZWN0OiBSZTog
W2Zvci1uZXh0IDQvNl0gbmV0L21seDU6IEZQR0EsIEFkZCBiYXNpYyBzdXBwb3J0IGZvcg0KPiA+
IElubm92YQ0KPiA+ID4gPg0KPiA+ID4gPiBPbiBTdW4sIE1heSAyOCwgMjAxNyBhdCAwNzoyMjoy
N0FNICswMDAwLCBJbGFuIFRheWFyaSB3cm90ZToNCj4gPiA+ID4NCj4gPiA+ID4gPiBUaGlzIGlz
IG5laXRoZXIgUENJLWJhciBtYXBwZWQsIG5vciBtYWlsYm94IGNvbW1hbmQuDQo+ID4gPiA+ID4g
VGhlIEZQR0EgaXMgaW5kZWVkIGEgYnVtcC1vbi10aGUtd2lyZS4NCj4gPiA+ID4gPiAoSXQgaGFz
IEkyQyB0byB0aGUgQ1g0IGNoaXAsIGJ1dCB0aGF0IGlzIGZvciBkZWJ1ZyBwdXJwb3NlcywgYW5k
DQo+IHRvbw0KPiA+ID4gPiBzbG93DQo+ID4gPiA+ID4gdG8gcGVyZm9ybSByZWFsIHByb2dyYW1t
aW5nKQ0KPiA+ID4gPg0KPiA+ID4gPiBXYWl0Li4gU28gaWYgaXQgdHJ1ZWx5IGhhcyBub3RoaW5n
IHRvIGRvIHdpdGggdGhlIGV4aXN0aW5nIG1lbGxhbm94DQo+ID4gPiA+IGRyaXZlciwgdGhlbiBu
b3RoaW5nIG1vcmUgdGhhbiB0aGUgZnBnYSBsb2FkZXIgc2hvdWxkIGJlIGluIHRoZSBtbHg1DQo+
ID4gPiA+IGRpcmVjdG9yeT8NCj4gPiA+DQo+ID4gPiBUcnVlLCBleGNlcHQgaW4gc3BlY2lmaWMg
Y2FzZXMgd2hlbiB0aGUgRlBHQSBtYXkgbWFuZ2xlIHRoZSBwYWNrZXRzIGluDQo+ID4gPiBhIHdh
eSB0aGF0IHRoZSBuZXRkZXZpY2UgY29uZmlndXJlcywgYW5kIHRoZSBkcml2ZXIgbmVlZHMgdG8g
YWRhcHQgdGhlDQo+ID4gPiBkYXRhIHBhdGguDQo+ID4NCj4gPiA+IFN1Y2ggaXMgdGhlIGNhc2Ug
b2YgSVBTZWMgYW5kIFRMUyBvZmZsb2Fkcy4NCj4gPiA+IFRob3NlIGFyZSB0aWVkIHRvIHRoZSBt
bHg1IEV0aGVybmV0IGRyaXZlciAoaXNvbGF0ZWQgd2l0aCBhIGtjb25maWcpLg0KPiA+DQo+ID4g
QnV0IHRoZXJlIGlzIG5vdGhpbmcgc3RvcHBpbmcgdGhpcyBzb3J0IG9mIEZQR0EgbWFuZ2xpbmcg
bG9naWMgYmVpbmcNCj4gPiBkb3duc3RyZWFtIG9mIGFueSBOSUMsIE1lbGxhbm94IGlzIGp1c3Qg
dGhlIGZpcnN0IHRvIGRvIHRoaXMuDQo+ID4NCj4gPiBJIHRoaW5rIHlvdSdkIGJlIGJldHRlciB0
byBhZGQgc29tZXRoaW5nIHRvIHRoZSBuZXQgc3RhY2sgdG8gbW9kZWwNCj4gPiB0aGlzIHBvc3Qt
bmljIG1hbmdsaW5nIGhhcmR3YXJlLCB0aGFuIHRyeWluZyB0byBoaWRlIGl0IGluIGEgZHJpdmVy
Lg0KPiANCj4gT2YgY291cnNlLg0KPiANCj4gRm9yIElQU2VjLCB0aGlzIGlzIGFscmVhZHkgaW4g
dGhlIGtlcm5lbC4NCj4gU2VlIHRoaXMgcGF0Y2hzZXQ6DQo+IGh0dHA6Ly93d3cubWFpbC1hcmNo
aXZlLmNvbS9uZXRkZXZAdmdlci5rZXJuZWwub3JnL21zZzE2Mjg3Ni5odG1sDQoNClNvcnJ5LCBJ
IHBvaW50ZWQgYXQgdGhlIFJGQyBieSBtaXN0YWtlLg0KDQpUaGlzIGlzIHRoZSByZWxldmFudCBw
dWxsIHJlcXVlc3Q6DQpodHRwczovL3BhdGNod29yay5vemxhYnMub3JnL3BhdGNoLzc1MjcwNy8N
Cg0KPiANCj4gRm9yIFRMUywgRGF2ZSBXYXRzb24gaXMgd29ya2luZyB3aXRoIG91ciBndXlzIHRv
IGFkZCBpdC4NCj4gDQo+ID4NCj4gPiBKYXNvbg0K
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
