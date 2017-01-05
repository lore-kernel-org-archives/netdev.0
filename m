From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] net: make ndo_get_stats64 a void
	function
Date: Thu, 05 Jan 2017 13:18:45 -0500 (EST)
Message-ID: <20170105.131845.1605952043383659916.davem@davemloft.net>
References: <20170105173136.2817-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-7"
Content-Transfer-Encoding: base64
Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	oss-drivers-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org
To: stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170105173136.2817-1-sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

RnJvbTogU3RlcGhlbiBIZW1taW5nZXIgPHN0ZXBoZW5AbmV0d29ya3BsdW1iZXIub3JnPg0KRGF0
ZTogVGh1LCAgNSBKYW4gMjAxNyAwOTozMTozNiAtMDgwMA0KDQo+IFRoZSBuZXR3b3JrIGRldmlj
ZSBvcGVyYXRpb24gZm9yIHJlYWRpbmcgc3RhdGlzdGljcyBpcyBvbmx5IGNhbGxlZA0KPiBpbiBv
bmUgcGxhY2UsIGFuZCBpdCBpZ25vcmVzIHRoZSByZXR1cm4gdmFsdWUuIEhhdmluZyBhIHN0cnVj
dHVyZQ0KPiByZXR1cm4gdmFsdWUgaXMgcG90ZW50aWFsbHkgY29uZnVzaW5nIGJlY2F1c2Ugc29t
ZSBmdXR1cmUgZHJpdmVyIGNvdWxkDQo+IGluY29ycmVjdGx5IGFzc3VtZSB0aGF0IHRoZSByZXR1
cm4gdmFsdWUgd2FzIHVzZWQuDQo+IA0KPiBGaXggYWxsIGRyaXZlcnMgd2l0aCBuZG9fZ2V0X3N0
YXRzNjQgdG8gaGF2ZSBhIHZvaWQgZnVuY3Rpb24uDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBTdGVw
aGVuIEhlbW1pbmdlciA8c3RoZW1taW5AbWljcm9zb2Z0LmNvbT4NCg0KWW91IG1pc3NlZCBhdCBs
ZWFzdCBvbmUgbmV3IHdhcm5pbmcsIHBsZWFzZSBkbyBhIGZyZXNoIGFsbG1vZGNvbmZpZyBidWls
ZA0KYW5kIHdhdGNoIHRoZSBsb2dzLg0KDQpkcml2ZXJzL25ldC9ldGhlcm5ldC9icm9hZGNvbS9i
bngyLmM6IEluIGZ1bmN0aW9uIKFibngyX2dldF9zdGF0czY0ojoNCmRyaXZlcnMvbmV0L2V0aGVy
bmV0L2Jyb2FkY29tL2JueDIuYzo2ODMwOjEwOiB3YXJuaW5nOiChcmV0dXJuoiB3aXRoIGEgdmFs
dWUsIGluIGZ1bmN0aW9uIHJldHVybmluZyB2b2lkDQoNClRoYW5rcy4NCl9fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9w
ZW52c3dpdGNoLm9yZwpodHRwczovL21haWwub3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGlu
Zm8vb3ZzLWRldgo=
