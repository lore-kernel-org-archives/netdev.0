From: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Sun, 11 Jun 2017 05:59:04 +0000
Message-ID: <AM4PR0501MB19401208254971445E61367EDBCC0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <AM4PR0501MB194037FF8F17466BC9ECC73DDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <AM4PR0501MB19409139227E11A4A7F82F0FDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170601153704.GA1680@obsidianresearch.com>
 <AM4PR0501MB19404B83A69B87AFB1326B45DBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170605151724.GA20182@obsidianresearch.com>
 <AM4PR0501MB194008AAABEB6AAAA2ADFC82DBCB0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170606161709.GA8671@obsidianresearch.com>
 <CALzJLG9Rdjme2piWX+CDeHZZebWArM_wGjLJPh8=COOxBHuFkw@mail.gmail.com>
 <20170607154858.GA30124@obsidianresearch.com>
 <CALzJLG8epxWp1pmTd_fxOUfzXF5YoOFfnrRBJ0-YZVL1Gi_yOw@mail.gmail.com>
 <20170607192132.GA10929@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jsorensen-b10kYP2dOMg@public.gmane.org" <jsorensen-b10kYP2dOMg@public.gmane.org>,
        Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alan Tull <atull-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>,
        "yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170607192132.GA10929-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBKYXNvbiBHdW50aG9ycGUgW21h
aWx0bzpqZ3VudGhvcnBlQG9ic2lkaWFucmVzZWFyY2guY29tXQ0KPiBTdWJqZWN0OiBSZTogW2Zv
ci1uZXh0IDQvNl0gbmV0L21seDU6IEZQR0EsIEFkZCBiYXNpYyBzdXBwb3J0IGZvciBJbm5vdmEN
Cj4gDQoNCg0KPiA+ID4gVGhpcyBrZWVwIGdldHRpbmcgbW9yZSB1Z2x5IDooDQo+ID4gPg0KPiA+
ID4gV2hhdCBhYm91dCBzZWN1cml0eT8gV2hhdCBpZiB1c2VyIHNwYWNlIHNlbmRzIHNvbWUgcmF3
IHBhY2tldHMgdG8gdGhlDQo+ID4gPiBGUEdBIC0gY2FuIGl0IHJlcHJvZ3JhbSB0aGUgSVNQRUMg
c2V0dGluZ3Mgb3Igd29yc2U/DQo+ID4gPg0KPiA+DQo+ID4gTm8gc3VjaCB0aGluZy4gVGhpcyBR
UCBpcyBvbmx5IGZvciBpbnRlcm5hbCBkcml2ZXIvSFcgY29tbXVuaWNhdGlvbnMsDQo+ID4gYXMg
aXQgaXMgZmFzdGVyIGZyb20gdGhlIGV4aXN0aW5nIGNvbW1hbmQgaW50ZXJmYWNlLg0KPiA+IGl0
IGlzIG5vdCBtZWFudCB0byBiZSBleHBvc2VkIGZvciBhbnkgcmF3IHVzZXIgc3BhY2UgdXNhZ2Vz
IGF0IGFsbCwNCj4gPiB3aXRob3V0IHByb3BlciBzdGFuZGFyZCBBUEkgYWRhcHRlciBvZiBjb3Vy
c2UuDQo+IA0KPiBJJ20gbm90IGFza2luZyBhYm91dCB0aGUgUVAsIEknbSBhc2tpbmcgd2hhdCBo
YXBwZW5zIGFmdGVyIHRoZSBOSUMNCj4gcGFydC4gWW91IHVzZSBST0NFIHBhY2tldHMgdG8gY29u
dHJvbCB0aGUgRlBHQS4gV2hhdCBwcmV2ZW50cw0KPiB1c2Vyc3BhY2UgZnJvbSBmb3JjaWJseSBj
b25zdHJ1Y3Rpbmcgcm9jZSBwYWNrZXRzIGFuZCBzZW5kaW5nIHRoZW0gdG8NCj4gdGhlIEZQR0Eu
IEhvdyBkb2VzIHRoZSBGUEdBIGtub3cgZm9yIGNlcnRhaW4gdGhlIHBhY2tldCBjYW1lIGZyb20g
dGhlDQo+IGtlcm5lbCBRUCBhbmQgbm90IHNvbWVwbGFjZSBlbHNlLg0KPiANCj4gVGhpcyBpcyBl
c3BlY2lhbGx5IHRydWUgZm9yIG1seCBuaWNzIGFzIHRoZXJlIGFyZSBtYW55IHJhdyBwYWNrZXQN
Cj4gYnlwYXNzIG1lY2hhbmlzbXMgYXZhaWxhYmxlIHRvIHVzZXJzcGFjZS4NCg0KSGkgSmFzb24s
DQoNClRoZSBkZXZpY2UgdXNlcyBpbnRlcm5hbCBzaWduYWxpbmcgdGhhdCBlbnN1cmVzIHRoYXQg
bm8gZW50aXR5IG90aGVyIHRoYW4gdGhlIG1seDUgZHJpdmVyIGNhbiB0YWxrIG92ZXIgdGhlIEZQ
R0EgY2hhbm5lbC4NClRoaXMgaXMgYWxzbyB0aGUgcmVhc29uIHdoeSB0aGlzIGlzIG5vdCBhICJV
TFAgaW4gYSAgZHJpdmVyIiwgYnV0IHJhdGhlciBhbiBpbnRlcm5hbCBidXMgdGhhdCBoYXBwZW5z
IHRvIHVzZSBzb21lIG9mIG91ciBleGlzdGluZyBIVyBmZWF0dXJlcy4NCg0KQXMgZXhwbGFpbmVk
IGVhcmxpZXIsIHRoaXMgImJ1cyIgaXMgYW4gaW50ZXJuYWwgZGV2aWNlIGltcGxlbWVudGF0aW9u
IGlzc3VlLCBhbmQgaGFzIG5vdGhpbmcgdG8gZG8gd2l0aCB0aGUgbmV0d29yayBvciBSRE1BIHN0
YWNrLg0KDQpJbGFuLg0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
