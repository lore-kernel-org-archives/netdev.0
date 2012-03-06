From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver support
Date: Tue, 06 Mar 2012 13:03:11 +0100
Message-ID: <878vjeuebk.fsf@nemi.mork.no>
References: <1330528507-16551-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45620 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759176Ab2CFMD2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 07:03:28 -0500
In-Reply-To: <1330528507-16551-1-git-send-email-bjorn@mork.no>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Wed, 29 Feb 2012 16:15:02 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> Note that the netdev patches still depend on the 3 first patches of t=
his
> set, and should not be applied independently. The 3 first do not yet
> apply to net-next, as they depend on other patches in usb-next and
> linux-next. Please let me know if this sort of cross-system
> patch set should be handled otherwise.
>
> All 5 patches are verified to apply cleanly to linux-next tag next-20=
120229.
> Patches 1-3 are verified to apply to usb-next commit aac1fc386
> Patches 4-5 are verified to apply to net-next commit 9100eb012 , but =
will
> cause build errors there due to the lack of the required 3 first patc=
hes
> as noted above.
>
> Bj=C3=B8rn Mork (5):
>   usb: cdc-wdm: split out reusable parts of probe
>   usb: cdc-wdm: adding list lookup indirection
>   usb: cdc-wdm: adding usb_cdc_wdm_register subdriver support
>   net: qmi_wwan: support devices having a shared QMI/wwan interface
>   net: qmi_wwan: add Gobi and Pantech UML290 device IDs
>

Hello Greg,

I believe I may have promised to ping you when these patches were
ready.  Please apply patch 1-3 from this series to your usb-next branch
(for Linux 3.4). They were acked by Oliver a week ago.

Patches 4 and 5 (for netdev) will have to wait until the first 3 are
merged.


Bj=C3=B8rn
