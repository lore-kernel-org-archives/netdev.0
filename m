From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 12:57:50 +0200
Message-ID: <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
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
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00248c6a66bab59acc04bea6f901
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:37506 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759764Ab2D0K5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 06:57:51 -0400
In-Reply-To: <20120427101732.GX3157@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--00248c6a66bab59acc04bea6f901
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 27, 2012 at 12:17 PM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Fri, Apr 27, 2012 at 12:12:13PM +0200, Sedat Dilek wrote:
>
>> >> >> >> Are you planning to or even working on support (for) 8361 devic=
es?
>> >> >> >
>> >> >> > I don't have any such plans, and I don't know of anyone who does=
.
>> >> >>
>> >> >> Does 8361 require firmware support?
>> >> >
>> >> > What do you mean by that?
>> >>
>> >> IIRC ath5k for example needs no external firmware file.
>> >
>> > The 8361 requires firmware to be loaded into it before it'll do
>> > anything useful.
>> >
>> >
>> >> >> Does a firmware file exist (name?)?
>> >> >
>> >> > There's firmware for the 8361 out there, however, that version of
>> >> > the firmware implements a firmware API that is different from the
>> >> > one that mwl8k currently implements.
>> >> >
>> >> > You could add 8361 support to mwl8k, but then you'd have to go over
>> >> > all the firmware command invocations in mwl8k and make sure that th=
ey
>> >> > will work on the 8361 firmware that you're trying to support as wel=
l.
>> >>
>> >> Without having a 8361 this will be even harder to walk through.
>> >>
>> >> Anyway, thanks for your detailed explanations.
>> >>
>> >> What's the alternative for such affected users?
>> >> Use ndis-wrapper?
>> >
>> > I'm not sure. =C2=A0I've never tried to get a 8361 work under Linux.
>>
>> Just found on [1] this same wrong patch in [2] :-).
>> Dunno if [3] worked and from where they have stolen fw-files.
>>
>> - Sedat -
>>
>> [1] https://dev.openwrt.org/ticket/7209
>> [2] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_fix_pci_id.patc=
h
>> [3] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_8361p.patch
>
> I doubt that [3] is really all that's needed to make it work. =C2=A0But i=
f
> there's someone for whom it works, I'd like them to run some tests on
> mwl8k + [3] on 88w8361p.

Just asked lautriv to do so (he will do against linux-3.3.3), lets' see.
Also, I refreshed and adapted a bit the instructions (see attachment).

- Sedat -

--00248c6a66bab59acc04bea6f901
Content-Type: text/plain; charset=US-ASCII; name="mwl8k_extract_firmware.txt"
Content-Disposition: attachment; filename="mwl8k_extract_firmware.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h1j4m2kc0

IyMjIEhFTFAtMTogaHR0cHM6Ly9mb3J1bS5vcGVud3J0Lm9yZy92aWV3dG9waWMucGhwP3BpZD0x
MDMyNDMjcDEwMzI0MwojIyMgSEVMUC0yOiBodHRwczovL2ZvcnVtLm9wZW53cnQub3JnL3ZpZXd0
b3BpYy5waHA/cGlkPTExMDAwNCNwMTEwMDA0CgojIyMgRnJvbSBIRUxQLTE6CgpUbyBleHRyYWN0
IHRoZSBmaXJtd2FyZSBmb3IgdGhlIG13bDhrIGRyaXZlciwgb3BlbiB5b3VyIFVidW50dSB0ZXJt
aW5hbDoKCnN1ZG8gYXB0LWdldCBpbnN0YWxsIGNhYmV4dHJhY3QgdW5zaGllbGQKCm1rZGlyIG13
bDhrCmNkIG13bDhrCgp3Z2V0IC1PIG1ydjhrX2V4dHJhY3RfZncuYyAnaHR0cDovL21hcmMuaW5m
by8/bD1saW51eC13aXJlbGVzcyZtPTEyNjU0MDY3NDQxOTMzMCZxPXAzJwp3Z2V0IGZ0cDovL2Rv
d25sb2Fkcy5uZXRnZWFyLmNvbS9maWxlcy93bjMxMXRfNF8yX3NldHVwLmV4ZQoKbWtkaXIgbWVz
cwpjYWJleHRyYWN0IC1GIERpc2sxL2RhdGEqLiogLWQgbWVzcyB3bjMxMXRfNF8yX3NldHVwLmV4
ZQp1bnNoaWVsZCAtZyBEcml2ZXIgLWQgbWVzcyB4IG1lc3MvRGlzazEvZGF0YTEuY2FiCmdjYyAt
byBtcnY4a19leHRyYWN0X2Z3IG1ydjhrX2V4dHJhY3RfZncuYwouL21ydjhrX2V4dHJhY3RfZncg
bWVzcy9Ecml2ZXIvbmV0bXcxNDUuc3lzCnJtIC1yIG1lc3MKCm1kNXN1bSAtYiAqLmZ3Cm12IGZt
aW1hZ2VfOFhYMS5mdyBmbWltYWdlXzgzNjMuZncKbXYgaGVscGVyXzhYWDEuZncgaGVscGVyXzgz
NjMuZncKCiMjIyBGcm9tIEhFTFAtMjogRm9yIE1hcndlbGwgODM2MVAKCm1kNXN1bSAtYiAqLmZ3
IHwgZWdyZXAgJzQ4Yzc5YjA4NWY3ZjVhNTkwZDNkYmMxNTY0N2U1MTlmfDBmZTExZjQxNWFkYmJk
NWU4Y2EwMzY0MTcwNWM0YTZjJwpbIE9VVFBVVCBdCjQ4Yzc5YjA4NWY3ZjVhNTkwZDNkYmMxNTY0
N2U1MTlmICpmbWltYWdlXzhYWDAuZncKMGZlMTFmNDE1YWRiYmQ1ZThjYTAzNjQxNzA1YzRhNmMg
KmhlbHBlcl84WFgwLmZ3CgptdiBmbWltYWdlXzhYWDAuZncgZm1pbWFnZV84MzYxcC5mdwptdiBo
ZWxwZXJfOFhYMC5mdyBoZWxwZXJfODM2MXAuZncKCiMjIyBQQVRDSDogaHR0cHM6Ly9kZXYub3Bl
bndydC5vcmcvYXR0YWNobWVudC90aWNrZXQvNzIwOS9td2w4a184MzYxcC5wYXRjaAoKCi1kaWxl
a3MgLy8gMjctQXByLTIwMTIKCg==
--00248c6a66bab59acc04bea6f901--
