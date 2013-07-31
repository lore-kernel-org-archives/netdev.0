From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] vxlan: fix rcu related warnings
Date: Wed, 31 Jul 2013 10:57:14 -0700
Message-ID: <CALnjE+obgWjqDhuyWUJ=kimMKQbbweenRdxbU1ZCBWBP_qe8Zg@mail.gmail.com>
References: <20130730131844.7d3f92de@nehalam.linuxnetplumber.net>
	<CALnjE+qx1L5p6CzFcd4nMTvWbxm-7_bz10wjbuUJdt12Q4Kqpg@mail.gmail.com>
	<20130730160245.4b7b84a1@nehalam.linuxnetplumber.net>
	<1375225499.10515.31.camel@edumazet-glaptop>
	<20130730173516.3d536077@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b6774429b9a6004e2d27495
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:51120 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753289Ab3GaR5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 13:57:16 -0400
Received: by mail-qe0-f41.google.com with SMTP id a11so564055qen.14
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 10:57:14 -0700 (PDT)
In-Reply-To: <20130730173516.3d536077@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b6774429b9a6004e2d27495
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Jul 30, 2013 at 5:35 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 30 Jul 2013 16:04:59 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> On Tue, 2013-07-30 at 16:02 -0700, Stephen Hemminger wrote:
>>
>> > Which version of sparse? I don't see this with latest version.
>>
>> Make sure you have CONFIG_SPARSE_RCU_POINTER=y
>>
>>
>
> I have it enabled. And am using latest version from git.

Attached patch fixes warnings for me.

--047d7b6774429b9a6004e2d27495
Content-Type: application/octet-stream; name="0002-vxlan-fix-rcu-warn.patch"
Content-Disposition: attachment; filename="0002-vxlan-fix-rcu-warn.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hjsu66yk0

RnJvbSA4MDU2NTBiYzQzNWI5OWNiY2MwMjgyOTAzOWEwYzNhODc3NDE2ZmQ5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBQcmF2aW4gQiBTaGVsYXIgPHBzaGVsYXJAbmljaXJhLmNvbT4K
RGF0ZTogV2VkLCAzMSBKdWwgMjAxMyAxMDo1Mjo1OSAtMDcwMApTdWJqZWN0OiBbUEFUQ0ggbmV0
LW5leHRdIHZ4bGFuOiBmaXggcmN1IHdhcm4uCgotLS0KIGRyaXZlcnMvbmV0L3Z4bGFuLmMgfCAg
ICAyICstCiAxIGZpbGVzIGNoYW5nZWQsIDEgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkK
CmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC92eGxhbi5jIGIvZHJpdmVycy9uZXQvdnhsYW4uYwpp
bmRleCAzMTcxOGM2Li5lNGQxNTEzIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC92eGxhbi5jCisr
KyBiL2RyaXZlcnMvbmV0L3Z4bGFuLmMKQEAgLTE3Niw3ICsxNzYsNyBAQCBzdGF0aWMgaW5saW5l
IHN0cnVjdCBobGlzdF9oZWFkICp2c19oZWFkKHN0cnVjdCBuZXQgKm5ldCwgX19iZTE2IHBvcnQp
CiAvKiBGaXJzdCByZW1vdGUgZGVzdGluYXRpb24gZm9yIGEgZm9yd2FyZGluZyBlbnRyeS4KICAq
IEd1YXJhbnRlZWQgdG8gYmUgbm9uLU5VTEwgYmVjYXVzZSByZW1vdGVzIGFyZSBuZXZlciBkZWxl
dGVkLgogICovCi1zdGF0aWMgaW5saW5lIHN0cnVjdCB2eGxhbl9yZHN0IF9fcmN1ICpmaXJzdF9y
ZW1vdGVfcmN1KHN0cnVjdCB2eGxhbl9mZGIgKmZkYikKK3N0YXRpYyBpbmxpbmUgc3RydWN0IHZ4
bGFuX3Jkc3QgKmZpcnN0X3JlbW90ZV9yY3Uoc3RydWN0IHZ4bGFuX2ZkYiAqZmRiKQogewogCXJl
dHVybiBsaXN0X2VudHJ5X3JjdShmZGItPnJlbW90ZXMubmV4dCwgc3RydWN0IHZ4bGFuX3Jkc3Qs
IGxpc3QpOwogfQotLSAKMS43LjEKCg==
--047d7b6774429b9a6004e2d27495--
