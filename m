From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] Revert "net: cx82310_eth: use common match macro"
Date: Thu, 19 Mar 2015 09:21:30 +0100
Message-ID: <87y4mtcs8l.fsf@nemi.mork.no>
References: <1426716061-20953-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426716061-20953-1-git-send-email-linux@rainbow-software.org>
	(Ondrej Zary's message of "Wed, 18 Mar 2015 23:01:01 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ondrej Zary <linux@rainbow-software.org> writes:

> This reverts commit 11ad714b98f6d9ca0067568442afe3e70eb94845 because
> it breaks cx82310_eth.
>
> The custom USB_DEVICE_CLASS macro matches
> bDeviceClass, bDeviceSubClass and bDeviceProtocol
> but the common USB_DEVICE_AND_INTERFACE_INFO matches
> bInterfaceClass, bInterfaceSubClass and bInterfaceProtocol instead, w=
hich are
> not specified.

Ouch.  What ever made me do that? Thanks a lot for fixing it!

This bug was introduced as long ago as v3.7, so the fix should go into
every currently maintained stable branch since that.


Bj=C3=B8rn
