From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: about [PATCH] net:usb:cdc_ncm: fix that tag Huawei devices as wwan
Date: Fri, 26 Jun 2015 11:20:32 +0200
Message-ID: <87oak27rmn.fsf@nemi.mork.no>
References: <SNT147-W99A0E937260823EBAA1FFB3B90@phx.gbl>
	<CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww@mail.gmail.com>
	<87ioapl55s.fsf@nemi.mork.no>
	<30508675-5839-4E65-975A-4CFC5B1C5E24@holtmann.org>
	<87a8w1kz3a.fsf@nemi.mork.no>
	<EA652056-E807-4977-AF2A-8BF7E3E41DFD@holtmann.org>
	<SNT147-W34897D8EB12DAD3DE657EDB3A60@phx.gbl>
	<SNT147-W52BB193529481B6D3BFA57B3AF0@phx.gbl>
	<73FEE7778B75214796F3C8DE1ABE6DD66ED26A22@szxema508-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "torvalds\@linux-foundation.org" <torvalds@linux-foundation.org>,
	"aleksander\@aleksander.es" <aleksander@aleksander.es>,
	"dcbw\@redhat.com" <dcbw@redhat.com>,
	"oliver\@neukum.org" <oliver@neukum.org>,
	"ben.hutchings\@codethink.co.uk" <ben.hutchings@codethink.co.uk>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"marcel\@holtmann.org" <marcel@holtmann.org>,
	"xiaomao0213\@hotmail.com" <xiaomao0213@hotmail.com>,
	Zhangyuhan <zhangyuhan@huawei.com>
To: "Chenqi \(jakio\)" <cqi.chen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35788 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbbFZJXL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 05:23:11 -0400
In-Reply-To: <73FEE7778B75214796F3C8DE1ABE6DD66ED26A22@szxema508-mbx.china.huawei.com>
	(Chenqi's message of "Thu, 25 Jun 2015 08:55:04 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Chenqi (jakio)" <cqi.chen@huawei.com> writes:

> Hi, All,
>
> I'm from Huawei Technologies Co., Ltd, working in mobile broadband
> devices department.
>
> Huawei's broadband card don't support wwan in linux OS, there are
> several historical reasons:
>
> 1.  Huawei produced dozens of broadband card types in past years, and
> our customers/users integrate our products in many different OS
> versions, We need give customer/user a continuous method to let them
> use convenience.
>
> 2.  Wwan connection need application support, while we didn't test
> them for compatibility.
>
> Meanwhile, we have provided serial port to let other existing
> applications dial-up the connection
>
> I understand that you guys have some confusion why the Huawei
> broadband cards support wwan in windows OS but not in linux OS with
> the same device ID.  Since wwan standard is used firstly in windows
> OS, when we pronounced to support this feature, wwan is not enabled i=
n
> linux.  So we keep the card's behavior in linux same as before.

The Linux kernel/drivers/userspace always will attempt to use hardware
in the same way Windows use it, or at least as close as we are able to
get.  The reason is simple: A billion (or whatever) Windows users is th=
e
best test lab you can get.

You may not agree with this strategy, but as a hardware vendor you have
to expect it to happen.  The community will continue to develop support
based on that assumption, even if you try to accommodate Linux by addin=
g
addiotional "Linux specific" features or modes.

> This wwan patch has great influence on our broadband cards, we have
> tested many our broadband cards with this kernel version, and this
> compatible issue is common.  So please approve our modification for
> this problem.

If noone else has any comments or objections here, then I am certainly
not going to object to the proposed patch.

Please go ahead and submit the patch formally.  I am going to keep my
big mouth shut :)

> I think the root cause of this issue is this kernel version trait the
> NCM as wwan devtype, maybe we can add a flag in usb descriptor in
> future to indicate whether the device support wwan or not, then Huawe=
i
> can support wwan feature later for the newest product without
> introducing compatible issues.
>
> BTW: if we want to join the usb-ethernet kernel evolution in linux,
> which forum or organization should we join in?  We can participate in
> it to avoid similar problems.

USB networking drivers are discussed, along with other network drivers,
on the netdev@vger.kernel.org mailing list.  Preferable with a copy to
the linux-usb@vger.kernel.org mailing list for USB expert review.

But as you point out above:  wwan connections need application support.
Userspace projects like ModemManager, oFono, libmbim, libqmi, umbim,
uqmi and probably more, each have their own development forums/mailing
lists.  This is where the most important part of the wwan developemt
takes place.

Huawei have already made important contributions to the development of
both Linux wwan drivers and userspace applications.  I am sure all thos=
e
projects will appreciate any further help Huawei are able to offer.

Thanks a lot for your detailed introduction and explanation.


Bj=C3=B8rn
