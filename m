From: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 15:29:26 +0200
Message-ID: <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
References: <1335517711-6522-1-git-send-email-sedat.dilek@gmail.com>
	<20120427091405.GS3157@wantstofly.org>
	<CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com>
	<20120427094007.GU3157@wantstofly.org>
	<CA+icZUUiYwpHpqe5_kz1rLzTT13qQMwpNpDH7EOaRrVi_c8Z2Q@mail.gmail.com>
	<20120427094637.GV3157@wantstofly.org>
	<CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
	<20120427095842.GW3157@wantstofly.org>
	<CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
	<20120427101732.GX3157@wantstofly.org>
	<CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf30334f0fe69b4704bea917a1
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lautriv <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>,
	Jim Cromie <jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--20cf30334f0fe69b4704bea917a1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 27, 2012 at 12:57 PM, Sedat Dilek
<sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:
> On Fri, Apr 27, 2012 at 12:17 PM, Lennert Buytenhek
> <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org> wrote:
>> On Fri, Apr 27, 2012 at 12:12:13PM +0200, Sedat Dilek wrote:
>>
>>> >> >> >> Are you planning to or even working on support (for) 8361 devi=
ces?
>>> >> >> >
>>> >> >> > I don't have any such plans, and I don't know of anyone who doe=
s.
>>> >> >>
>>> >> >> Does 8361 require firmware support?
>>> >> >
>>> >> > What do you mean by that?
>>> >>
>>> >> IIRC ath5k for example needs no external firmware file.
>>> >
>>> > The 8361 requires firmware to be loaded into it before it'll do
>>> > anything useful.
>>> >
>>> >
>>> >> >> Does a firmware file exist (name?)?
>>> >> >
>>> >> > There's firmware for the 8361 out there, however, that version of
>>> >> > the firmware implements a firmware API that is different from the
>>> >> > one that mwl8k currently implements.
>>> >> >
>>> >> > You could add 8361 support to mwl8k, but then you'd have to go ove=
r
>>> >> > all the firmware command invocations in mwl8k and make sure that t=
hey
>>> >> > will work on the 8361 firmware that you're trying to support as we=
ll.
>>> >>
>>> >> Without having a 8361 this will be even harder to walk through.
>>> >>
>>> >> Anyway, thanks for your detailed explanations.
>>> >>
>>> >> What's the alternative for such affected users?
>>> >> Use ndis-wrapper?
>>> >
>>> > I'm not sure. =C2=A0I've never tried to get a 8361 work under Linux.
>>>
>>> Just found on [1] this same wrong patch in [2] :-).
>>> Dunno if [3] worked and from where they have stolen fw-files.
>>>
>>> - Sedat -
>>>
>>> [1] https://dev.openwrt.org/ticket/7209
>>> [2] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_fix_pci_id.pat=
ch
>>> [3] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_8361p.patch
>>
>> I doubt that [3] is really all that's needed to make it work. =C2=A0But =
if
>> there's someone for whom it works, I'd like them to run some tests on
>> mwl8k + [3] on 88w8361p.
>
> Just asked lautriv to do so (he will do against linux-3.3.3), lets' see.
> Also, I refreshed and adapted a bit the instructions (see attachment).
>
> - Sedat -

[ CC Jim Cromie ]

Now, with extracted firmware files renamed & copied to
/lib/firmware/mwl8k/ and applied patch (see attachment) against
Linux-3.4-rc4+ I am seeing with modinfo:

$ sudo modinfo mwl8k
filename:
/lib/modules/3.4.0-rc4-5-generic/kernel/drivers/net/wireless/mwl8k.ko
license:        GPL
author:         Lennert Buytenhek <buytenh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
version:        0.13
description:    Marvell TOPDOG(R) 802.11 Wireless Network Driver
firmware:       mwl8k/fmimage_8366_ap-2.fw
firmware:       mwl8k/fmimage_8366.fw
firmware:       mwl8k/helper_8366.fw
firmware:       mwl8k/fmimage_8687.fw
firmware:       mwl8k/helper_8687.fw
firmware:       mwl8k/fmimage_8363.fw
firmware:       mwl8k/helper_8363.fw
firmware:       mwl8k/fmimage_8361p.fw
firmware:       mwl8k/helper_8361p.fw
srcversion:     9E1479A05C8D67E6AE90746
alias:          pci:v000011ABd00002A43sv*sd*bc*sc*i*
alias:          pci:v000011ABd00002A40sv*sd*bc*sc*i*
alias:          pci:v000011ABd00002A30sv*sd*bc*sc*i*
alias:          pci:v000011ABd00002A2Bsv*sd*bc*sc*i*
alias:          pci:v000011ABd00002A24sv*sd*bc*sc*i*
alias:          pci:v000011ABd00002A0Csv*sd*bc*sc*i*
alias:          pci:v000011ABd00002A0Asv*sd*bc*sc*i*
alias:          pci:v000011ABd00002A02sv*sd*bc*sc*i* <--- 8361P:
0x2a02 PCI device-id
depends:        mac80211,cfg80211
vermagic:       3.4.0-rc4-5-generic SMP mod_unload modversions
parm:           ap_mode_default:Set to 1 to make ap mode the default
instead of sta mode (bool)

$ ls -l /lib/firmware/mwl8k/
insgesamt 456
-rw-r--r-- 1 root root  75848 Apr 27 13:49 fmimage_8361p.fw <---
8361P: Firmware image
-rw-r--r-- 1 root root 101780 M=C3=A4r 19 19:32 fmimage_8366_ap-1.fw
-rw-r--r-- 1 root root 101976 M=C3=A4r 19 19:32 fmimage_8366_ap-2.fw
-rw-r--r-- 1 root root  96664 M=C3=A4r 19 19:32 fmimage_8366.fw
-rw-r--r-- 1 root root  73252 Feb 23 20:07 fmimage_8687.fw
-rw-r--r-- 1 root root   2476 Apr 27 13:49 helper_8361p.fw <--- 8361P:
Helper image
-rw-r--r-- 1 root root   2476 M=C3=A4r 19 19:32 helper_8366.fw
-rw-r--r-- 1 root root   2476 Feb 23 20:07 helper_8687.fw

As said... ***compile-tested*** only here.

I had a short query with lautriv on #linux-wireless this afternoon:
* mwl8k kernel-module was autoloaded
* wlan0 interface got fired up
* ESSID was accepted
* logs reported 802.11bgn support is active
* (he tested on Linux-3.3.3)

With WPA/WPA2 lautriv had some problems as his installation was
missing wpasupplicant.
He setup a classic /etc/network/interfaces.
After resetting his router mwl8k worked nicely.

Unfortunately, he was on the run and promised me to send logs and do
more testing this evening.

So, Lennert if you want more testing - What? How? etc.

Thanks in advance.

- Sedat -

--20cf30334f0fe69b4704bea917a1
Content-Type: application/octet-stream;
	name="0001-mwl8k-Add-support-for-MWL8361P.patch"
Content-Disposition: attachment;
	filename="0001-mwl8k-Add-support-for-MWL8361P.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h1j76v0n1

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
--20cf30334f0fe69b4704bea917a1--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
