From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Sun, 29 May 2011 00:00:17 +0200
Message-ID: <BANLkTi=8aBj8QRr+RgH=enL1vVuQq61Avg@mail.gmail.com>
References: <1301005107.2714.113.camel@edumazet-laptop>
	<AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
	<1301005946.2714.130.camel@edumazet-laptop>
	<20110324.153623.45921344.davem@davemloft.net>
	<1301006652.2714.145.camel@edumazet-laptop>
	<AANLkTi=Xb3KCBKoVCcaVD5iyCtMCAnYaGF_DTeFQ0ays@mail.gmail.com>
	<AANLkTinh9Li7DGgSqcZ+p9peS5XrHWomerSvKTYwHZ9-@mail.gmail.com>
	<AANLkTi=hgOcwO8ojQBtmqbROS1qrhm5HCmq7tRxesc=6@mail.gmail.com>
	<AANLkTinQq=BAVS1FrH80+VukTfAK1OKOkjEH4=gwZkv6@mail.gmail.com>
	<1306488451.2029.107.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=90e6ba6e864c04af4504a45d2e1b
Cc: Hiroyuki Kawakatsu <hkawakat@gmail.com>,
	Kyle Moffett <kyle@moffetthome.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36300 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab1E1WAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2011 18:00:18 -0400
In-Reply-To: <1306488451.2029.107.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--90e6ba6e864c04af4504a45d2e1b
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Fri, May 27, 2011 at 11:27 AM, David Woodhouse <dwmw2@infradead.org> wro=
te:
> On Fri, 2011-03-25 at 02:25 +0100, Alessandro Suardi wrote:
>>
>> ...which didn't take that long - one last bugging question and I'm happi=
ly
>> =A0off to sleep; does ipid always come in the form of 0x followed by fou=
r
>> =A0bytes representing hex values ? In a perhaps inelegant but working wa=
y
>> =A0(I'm now writing through the VPN tunnel),
>>
>> =A0 sed 's/cache//;s/metric \?[0-9]\+ [0-9]\+//g;s/hoplimit
>> [0-9]\+//g;s/ipid 0x....//g'
>>
>> =A0appears to be Work For Me (TM).
>
> Please could I have a tested patch for vpnc-script?
>
> It now lives in its own repository at
> git://, http://git.infradead.org/users/dwmw2/vpnc-scripts.git because
> it's used by openconnect too, and has had various bug fixes for
> cross-platform support and IPv6 since it was forked from vpnc.

I downloaded the git version and checked - the one I use is the Fedora
 version which seems updated to perhaps two revisions behind git...
 anyway, attaching (in order to not mangle whitespace) the one-liner
 change that I've been using since without issues - to the point that I
 actually forgot having patched the script...

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")

--90e6ba6e864c04af4504a45d2e1b
Content-Type: application/octet-stream; name="vpnc-script.diff"
Content-Disposition: attachment; filename="vpnc-script.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_go93ri2z0

LS0tIHZwbmMtc2NyaXB0cy05MjM5YmQ4L3ZwbmMtc2NyaXB0CTIwMTAtMDItMjMgMTk6MTE6NTMu
MDAwMDAwMDAwICswMTAwCisrKyB2cG5jLXNjcmlwdHMtbmV3L3ZwbmMtc2NyaXB0CTIwMTEtMDUt
MjggMjM6NDk6MjguMDAwMDAwMDAwICswMjAwCkBAIC0xMzksNyArMTM5LDcgQEAKIAogaWYgWyAt
biAiJElQUk9VVEUiIF07IHRoZW4KIAlmaXhfaXBfZ2V0X291dHB1dCAoKSB7Ci0JCXNlZCAncy9j
YWNoZS8vO3MvbWV0cmljIFw/WzAtOV1cKyBbMC05XVwrLy9nO3MvaG9wbGltaXQgWzAtOV1cKy8v
ZycKKwkJc2VkICdzL2NhY2hlLy87cy9tZXRyaWMgXD9bMC05XVwrIFswLTldXCsvL2c7cy9ob3Bs
aW1pdCBbMC05XVwrLy9nO3MvaXBpZCAweC4uLi4vL2cnCiAJfQogCiAJc2V0X3ZwbmdhdGV3YXlf
cm91dGUoKSB7Cgo=
--90e6ba6e864c04af4504a45d2e1b--
