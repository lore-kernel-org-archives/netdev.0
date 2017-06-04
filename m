From: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Sun, 4 Jun 2017 07:51:24 +0000
Message-ID: <AM4PR0501MB19404B83A69B87AFB1326B45DBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170526030701.du4345mbprhcwjyi@ast-mbp>
 <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA@mail.gmail.com>
 <20170526175624.5xxflpf24je5673h@ast-mbp>
 <20170526181517.GA3860@obsidianresearch.com>
 <AM4PR0501MB1940330F0EBAA819C87C5278DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529153131.GB7924@obsidianresearch.com>
 <AM4PR0501MB1940D05A19F098286B99EAD0DBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529160252.GA27550@obsidianresearch.com>
 <AM4PR0501MB194037FF8F17466BC9ECC73DDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <AM4PR0501MB19409139227E11A4A7F82F0FDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170601153704.GA1680@obsidianresearch.com>
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
In-Reply-To: <20170601153704.GA1680-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBKYXNvbiBHdW50aG9ycGUgW21h
aWx0bzpqZ3VudGhvcnBlQG9ic2lkaWFucmVzZWFyY2guY29tXQ0KPiBTdWJqZWN0OiBSZTogW2Zv
ci1uZXh0IDQvNl0gbmV0L21seDU6IEZQR0EsIEFkZCBiYXNpYyBzdXBwb3J0IGZvciBJbm5vdmEN
Cj4gDQo+IE9uIE1vbiwgTWF5IDI5LCAyMDE3IGF0IDA0OjA5OjA2UE0gKzAwMDAsIElsYW4gVGF5
YXJpIHdyb3RlOg0KPiANCj4gPiA+IEZvciBJUFNlYywgdGhpcyBpcyBhbHJlYWR5IGluIHRoZSBr
ZXJuZWwuDQo+ID4gPiBTZWUgdGhpcyBwYXRjaHNldDoNCj4gPiA+IGh0dHA6Ly93d3cubWFpbC1h
cmNoaXZlLmNvbS9uZXRkZXZAdmdlci5rZXJuZWwub3JnL21zZzE2Mjg3Ni5odG1sDQo+ID4NCj4g
PiBTb3JyeSwgSSBwb2ludGVkIGF0IHRoZSBSRkMgYnkgbWlzdGFrZS4NCj4gPg0KPiA+IFRoaXMg
aXMgdGhlIHJlbGV2YW50IHB1bGwgcmVxdWVzdDoNCj4gPiBodHRwczovL3BhdGNod29yay5vemxh
YnMub3JnL3BhdGNoLzc1MjcwNy8NCj4gDQo+IFRoaXMgaXMgY29ubmVjdGluZyBpcHNlYyB0byBh
IG5ldGRldiwgd2hpbGUgSW5ub3ZhIHNlZW1zIHRvIGJlIGENCg0KSmFzb24sDQoNCiJuZXR3b3Jr
IGNvbm5lY3RlZCBpcHNlYyBhY2NlbGVyYXRvciBjb25maWd1cmVkIHVzaW5nIElQIHBhY2tldHMu
Ig0KTm8uIFRoaXMgaXMgaW5jb3JyZWN0Lg0KV2hlcmUgZGlkIHlvdSBnZXQgdGhhdCBmcm9tPw0K
DQpJdCBpcyBhbiBJUFNlYy1jYXBhYmxlIE5JQy4NClNlZSBoZXJlIGZvciBkZXRhaWxzOg0KaHR0
cDovL3d3dy5tZWxsYW5veC5jb20vcGFnZS9wcm9kdWN0c19keW4/cHJvZHVjdF9mYW1pbHk9MjQ5
Jm10YWc9cHJvZ3JhbW1hYmxlX25ldHdvcmtfYWRhcHRlcnMNCg0KVGhlIGRyaXZlciB3ZSBhcmUg
aW50ZW5kaW5nIHRvIHN1Ym1pdCBmb3IgaXQsIGludGVyZmFjZXMgd2l0aCB0aGUgbWVudGlvbmVk
IEFQSSBpbiB0aGUgcHVsbC1yZXF1ZXN0IChOZXRkZXYgeGRvIGNhbGxiYWNrcykNCg0KU28geW91
IGNvbmZpZ3VyZSBpdCBmcm9tIHVzZXJzcGFjZSB3aXRoIHJlZ3VsYXIgSVBTZWMgJ2lwIHhmcm0g
c3RhdGUnIGNvbW1hbmRzIG9yIG92ZXIgbmV0bGluayB3aXRoIHlvdXIgZmF2b3JpdGUgSUtFIGRh
ZW1vbi4NCg0KPiANCj4gVGhvc2UgdHdvIHRoaW5ncyBkb24ndCBzZWVtIHRvIGJlIHRoZSBzYW1l
Lg0KPiANCj4gSmFzb24NCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
