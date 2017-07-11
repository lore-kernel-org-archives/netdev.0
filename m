From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH V3] Set NTB format again after altsetting switch for Huawei devices
Date: Tue, 11 Jul 2017 23:14:48 +0200
Message-ID: <87bmoqad6f.fsf@miraculix.mork.no>
References: <20170711152152.30011-1-mrkiko.rs@gmail.com>
        <1499806256.29772.1.camel@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
        Christian Panton <christian@panton.org>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:46577 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753681AbdGKVO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 17:14:56 -0400
In-Reply-To: <1499806256.29772.1.camel@neukum.org> (Oliver Neukum's message of
        "Tue, 11 Jul 2017 22:50:56 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> writes:
> Am Dienstag, den 11.07.2017, 17:21 +0200 schrieb Enrico Mioso:
>> Some firmwares in Huawei E3372H devices have been observed to switch back
>> to NTB 32-bit format after altsetting switch.
>> This patch implements a driver flag to check for the device settings and
>> set NTB format to 16-bit again if needed.
>> The flag has been activated for devices controlled by the huawei_cdc_ncm=
.c
>> driver.
>
> Hi,
>
> does this cover reset_resume()?

AFAIK reset_resume doesn't really work for 3G/LTE modems.  Too much
state to restore both in firmware and network, with no well defined
protocol to restore it.

The only reason for having reset_resume in the modem drivers is that
quite a few modems have an SD reader. We need to support persist for the
usb-storage function, even if the modem functions fail.  There is no
reason to mess up the file system too.



Bj=C3=B8rn
