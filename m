From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Tue, 1 May 2012 15:54:49 +0200
Message-ID: <CA+icZUV=qtXwVxb+uvQJcsza0y+6k2LHJFFPnECY0M=QWBexaQ@mail.gmail.com>
References: <20120427094637.GV3157@wantstofly.org>
	<CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
	<20120427095842.GW3157@wantstofly.org>
	<CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
	<20120427101732.GX3157@wantstofly.org>
	<CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
	<CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
	<20120427185809.GZ3157@wantstofly.org>
	<CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
	<CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
	<20120501125102.GN3157@wantstofly.org>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf300fa9530ca58c04bef9eaf1
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lautriv <admin@coldplug.net>,
	Jim Cromie <jim.cromie@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:45465 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab2EANyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 09:54:50 -0400
In-Reply-To: <20120501125102.GN3157@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf300fa9530ca58c04bef9eaf1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, May 1, 2012 at 2:51 PM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Sun, Apr 29, 2012 at 12:25:21AM +0200, Sedat Dilek wrote:
>
>> > On 1st sight, logs look fine:
>> >
>> > [21:52:52] <lautriv> [ =C2=A0 =C2=A06.050967] ieee80211 phy0: 88w8361p=
 v4,
>> > 00173f3bdde3, STA firmware 2.1.4.25
>> >
>> > But WLAN connection is not that fast and stable as lautriv reports
>> > (several abnormalities were observed).
>> >
>> > I requested a tarball which includes:
>> > * dmesg (Linux-3.3.3)
>> > * e_n_a (/etc/network/interfaces)
>> > * ifconfig output
>> > * iwconfig output
>> > * iw_phy output
>> > * ps_axu (WPA) output
>> >
>> > lautriv will be so kind to be around on #linux-wireless/Freenode the
>> > next days (UTC+2: German/Swiss local-time).
>> > Just ping him.
>> >
>> > Hope you have fun, together!
>> >
>> > - Sedat -
>>
>> A new tarball from lautriv with same outputs as before, but now tested
>> with Linux-3.4-rc4.

[ CC hauke (OpenWrt) and Ben Hutchings (linux-firmware maintainer) ]

> The output looks good enough for me to ACK adding the PCI ID.
>
> Can the firmware being used here be submitted to the linux-firmware
> git tree?

I can't say much about the firmware [1] inclusion or the procedure of
it into linux-firmware [2].
Maybe, Ben can explain the procedure and what has to be considered
before inclusion in linux-firmware.
The original firmware and helper images were extracted from a Netgear
Windows driver [1].

>From what I read in the OpenWrt forum posting [3]: You wanted to care
for inclusion:

"Firmware isn't included in the kernel tree anymore, there's the
linux-firmware git tree for that these days. I will contact some
people at Marvell to ask whether 8361P firmware can be included
there."

Some more concerns...
Dunno, if [4] is really correct and how to use one and same device-id
for 8363 ***and*** 8361P:
...
{ PCI_VDEVICE(MARVELL, 0x2a02), .driver_data =3D MWL8363, },
...
Curious about a statement from hauke...

Adding the device-id in case of 8361P is not enough (see attached patch)

I am looking forward to having support for 8361P soon.

- Sedat -

P.S.: I have re-added Readme and patch as there are new CCs.

[1] ftp://downloads.netgear.com/files/wn311t_4_2_setup.exe
[2] http://git.kernel.org/?p=3Dlinux/kernel/git/firmware/linux-firmware.git=
;a=3Dsummary
[3] https://forum.openwrt.org/viewtopic.php?pid=3D110039#p110039
[4] https://dev.openwrt.org/changeset/21167

--20cf300fa9530ca58c04bef9eaf1
Content-Type: text/plain; charset=US-ASCII; name="mwl8k_extract_firmware_v2.txt"
Content-Disposition: attachment; filename="mwl8k_extract_firmware_v2.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h1p08vtg0

IyMjIyMgSE9XVE86IEV4dHJhY3QgdGhlIGZpcm13YXJlIGZvciB0aGUgbXdsOGsgTGludXggV0xB
TiBkcml2ZXIgIyMjIyMKCiMjIyBIRUxQLTE6IGh0dHBzOi8vZm9ydW0ub3BlbndydC5vcmcvdmll
d3RvcGljLnBocD9waWQ9MTAzMjQzI3AxMDMyNDMKIyMjIEhFTFAtMjogaHR0cHM6Ly9mb3J1bS5v
cGVud3J0Lm9yZy92aWV3dG9waWMucGhwP3BpZD0xMTAwMDQjcDExMDAwNAojIyMgVEhSRUFEOiBo
dHRwOi8vbWFyYy5pbmZvLz90PTEzMzU1MTc5MjYwMDAwNCZyPTEmdz0yCgojIyMgSW5zdGFsbCBz
b21lIHRvb2xzIHRvIGluc3BlY3QgZmlsZSBjb250YWluaW5nIGZpcm13YXJlIGJsb2IKCnN1ZG8g
YXB0LWdldCBpbnN0YWxsIGNhYmV4dHJhY3QgdW5zaGllbGQKCiMjIyBXb3JraW5nIGRpcmVjdG9y
eQoKbWtkaXIgbXdsOGsKY2QgbXdsOGsKCiMjIyBEb3dubG9hZCBjLWZpbGUgKGV4dHJhY3QgZmly
bXdhcmUpIGFuZCBXaW5kb3dzIHNldHVwIGZpbGUgKGluY2wuIGZpcm13YXJlKQoKbWtkaXIgZmls
ZXMKY2QgZmlsZXMKd2dldCAtTyBtcnY4a19leHRyYWN0X2Z3LmMgJ2h0dHA6Ly9tYXJjLmluZm8v
P2w9bGludXgtd2lyZWxlc3MmbT0xMjY1NDA2NzQ0MTkzMzAmcT1wMycKd2dldCBmdHA6Ly9kb3du
bG9hZHMubmV0Z2Vhci5jb20vZmlsZXMvd24zMTF0XzRfMl9zZXR1cC5leGUKCiMjIyBFeHRyYWN0
IGZpcm13YXJlIGJsb2IKCm1rZGlyIC50bXAgLi4vZmlybXdhcmUKY2FiZXh0cmFjdCAtRiBEaXNr
MS9kYXRhKi4qIC1kIC50bXAgd24zMTF0XzRfMl9zZXR1cC5leGUKdW5zaGllbGQgLWcgRHJpdmVy
IC1kIC50bXAgeCAudG1wL0Rpc2sxL2RhdGExLmNhYgpnY2MgLW8gbXJ2OGtfZXh0cmFjdF9mdyBt
cnY4a19leHRyYWN0X2Z3LmMKLi9tcnY4a19leHRyYWN0X2Z3IC50bXAvRHJpdmVyL25ldG13MTQ1
LnN5cwptdiAqLmZ3IC4uL2Zpcm13YXJlLwpybSAtciAtZiAudG1wCgojIyMgQ2hlY2sgTUQ1U1VN
IGFuZCByZW5hbWUgZmlybXdhcmUvaGVscGVyIGltYWdlIGZpbGVzIGZvciA4MzYxUC84MzYzCgpb
IEtub3duIE1ENVNVTVMgZm9yIDgzNjFQIF0KNDhjNzliMDg1ZjdmNWE1OTBkM2RiYzE1NjQ3ZTUx
OWYgKmZtaW1hZ2VfOFhYMC5mdwowZmUxMWY0MTVhZGJiZDVlOGNhMDM2NDE3MDVjNGE2YyAqaGVs
cGVyXzhYWDAuZncKCmNkIC4uL2Zpcm13YXJlCm1kNXN1bSAtYiAqLmZ3Cm12IGZtaW1hZ2VfOFhY
MC5mdyBmbWltYWdlXzgzNjFwLmZ3Cm12IGhlbHBlcl84WFgwLmZ3IGhlbHBlcl84MzYxcC5mdwpt
diBmbWltYWdlXzhYWDEuZncgZm1pbWFnZV84MzYzLmZ3Cm12IGhlbHBlcl84WFgxLmZ3IGhlbHBl
cl84MzYzLmZ3CgoKLWRpbGVrcyAvLyAyNy1BcHItMjAxMgoK
--20cf300fa9530ca58c04bef9eaf1
Content-Type: application/octet-stream;
	name="0001-mwl8k-Add-support-for-MWL8361P.patch"
Content-Disposition: attachment;
	filename="0001-mwl8k-Add-support-for-MWL8361P.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h1p0jv2k1

RnJvbSAxYTU4NmExZjIxZjgyMGRlMGVhMDZjNTM4MmE2OTE5MWQ5M2Q4MGZlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBGcmksIDI3IEFwciAyMDEyIDEzOjQ2OjAyICswMjAwClN1YmplY3Q6IFtQQVRDSF0gbXds
OGs6IEFkZCBzdXBwb3J0IGZvciBNV0w4MzYxUAoKRm9sbG93IGRpc2N1c3Npb24gaW4gWzFdIGZv
ciBtb3JlIGRldGFpbHMgYWJvdXQgYWRkaW5nIGRyaXZlcgpzdXBwb3J0IGFuZCBob3d0byBleHRy
YWN0IGZpcm13YXJlIGZpbGVzLgoKJCBzdWRvIG1vZGluZm8gbXdsOGsgfCBlZ3JlcCAtaSAnODM2
MXB8MmEwMicKZmlybXdhcmU6ICAgICAgIG13bDhrL2ZtaW1hZ2VfODM2MXAuZncKZmlybXdhcmU6
ICAgICAgIG13bDhrL2hlbHBlcl84MzYxcC5mdwphbGlhczogICAgICAgICAgcGNpOnYwMDAwMTFB
QmQwMDAwMkEwMnN2KnNkKmJjKnNjKmkqCgpDb21waWxlLXRlc3RlZCBhZ2FpbnN0IExpbnV4LTMu
NC1yYzQrLgoKWzFdIGh0dHA6Ly9tYXJjLmluZm8vP3Q9MTMzNTUxNzkyNjAwMDA0JnI9MSZ3PTIK
ClNpZ25lZC1vZmYtYnk6IFNlZGF0IERpbGVrIDxzZWRhdC5kaWxla0BnbWFpbC5jb20+Ci0tLQog
ZHJpdmVycy9uZXQvd2lyZWxlc3MvbXdsOGsuYyB8ICAgIDkgKysrKysrKysrCiAxIGZpbGUgY2hh
bmdlZCwgOSBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvd2lyZWxlc3Mv
bXdsOGsuYyBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL213bDhrLmMKaW5kZXggYjQ4Njc0Yi4uM2Vh
OWI4ZSAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvd2lyZWxlc3MvbXdsOGsuYworKysgYi9kcml2
ZXJzL25ldC93aXJlbGVzcy9td2w4ay5jCkBAIC01MjI1LDYgKzUyMjUsNyBAQCBzdGF0aWMgdm9p
ZCBtd2w4a19maW5hbGl6ZV9qb2luX3dvcmtlcihzdHJ1Y3Qgd29ya19zdHJ1Y3QgKndvcmspCiB9
CiAKIGVudW0geworCU1XTDgzNjFQID0gMCwKIAlNV0w4MzYzID0gMCwKIAlNV0w4Njg3LAogCU1X
TDgzNjYsCkBAIC01MjM1LDYgKzUyMzYsMTEgQEAgZW51bSB7CiAjZGVmaW5lIE1XTDhLXzgzNjZf
QVBfRlcoYXBpKSBfTVdMOEtfODM2Nl9BUF9GVyhhcGkpCiAKIHN0YXRpYyBzdHJ1Y3QgbXdsOGtf
ZGV2aWNlX2luZm8gbXdsOGtfaW5mb190YmxbXSBfX2RldmluaXRkYXRhID0geworCVtNV0w4MzYx
UF0gPSB7CisJCS5wYXJ0X25hbWUgICAgICA9ICI4OHc4MzYxcCIsCisJCS5oZWxwZXJfaW1hZ2Ug
ICA9ICJtd2w4ay9oZWxwZXJfODM2MXAuZnciLAorCQkuZndfaW1hZ2Vfc3RhCT0gIm13bDhrL2Zt
aW1hZ2VfODM2MXAuZnciLAorCX0sCiAJW01XTDgzNjNdID0gewogCQkucGFydF9uYW1lCT0gIjg4
dzgzNjMiLAogCQkuaGVscGVyX2ltYWdlCT0gIm13bDhrL2hlbHBlcl84MzYzLmZ3IiwKQEAgLTUy
NTUsNiArNTI2MSw4IEBAIHN0YXRpYyBzdHJ1Y3QgbXdsOGtfZGV2aWNlX2luZm8gbXdsOGtfaW5m
b190YmxbXSBfX2RldmluaXRkYXRhID0gewogCX0sCiB9OwogCitNT0RVTEVfRklSTVdBUkUoIm13
bDhrL2hlbHBlcl84MzYxcC5mdyIpOworTU9EVUxFX0ZJUk1XQVJFKCJtd2w4ay9mbWltYWdlXzgz
NjFwLmZ3Iik7CiBNT0RVTEVfRklSTVdBUkUoIm13bDhrL2hlbHBlcl84MzYzLmZ3Iik7CiBNT0RV
TEVfRklSTVdBUkUoIm13bDhrL2ZtaW1hZ2VfODM2My5mdyIpOwogTU9EVUxFX0ZJUk1XQVJFKCJt
d2w4ay9oZWxwZXJfODY4Ny5mdyIpOwpAQCAtNTI2NCw2ICs1MjcyLDcgQEAgTU9EVUxFX0ZJUk1X
QVJFKCJtd2w4ay9mbWltYWdlXzgzNjYuZnciKTsKIE1PRFVMRV9GSVJNV0FSRShNV0w4S184MzY2
X0FQX0ZXKE1XTDhLXzgzNjZfQVBfRldfQVBJKSk7CiAKIHN0YXRpYyBERUZJTkVfUENJX0RFVklD
RV9UQUJMRShtd2w4a19wY2lfaWRfdGFibGUpID0geworCXsgUENJX1ZERVZJQ0UoTUFSVkVMTCwg
MHgyYTAyKSwgLmRyaXZlcl9kYXRhID0gTVdMODM2MVAsIH0sCiAJeyBQQ0lfVkRFVklDRShNQVJW
RUxMLCAweDJhMGEpLCAuZHJpdmVyX2RhdGEgPSBNV0w4MzYzLCB9LAogCXsgUENJX1ZERVZJQ0Uo
TUFSVkVMTCwgMHgyYTBjKSwgLmRyaXZlcl9kYXRhID0gTVdMODM2MywgfSwKIAl7IFBDSV9WREVW
SUNFKE1BUlZFTEwsIDB4MmEyNCksIC5kcml2ZXJfZGF0YSA9IE1XTDgzNjMsIH0sCi0tIAoxLjcu
OS41Cgo=
--20cf300fa9530ca58c04bef9eaf1--
