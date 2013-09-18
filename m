From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Wed, 18 Sep 2013 20:33:16 +0200
Message-ID: <878uyu56ab.fsf@nemi.mork.no>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com>
	<878uyu6xjm.fsf@nemi.mork.no>
	<CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
	<87zjra5dpx.fsf@nemi.mork.no>
	<CACVXFVNp5Qj-EV+L=FezwFqRnFa7uRFca7Ju9=iTqU+DS1r-fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Oliver Neukum <oliver@neukum.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59673 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635Ab3IRSd3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 14:33:29 -0400
In-Reply-To: <CACVXFVNp5Qj-EV+L=FezwFqRnFa7uRFca7Ju9=iTqU+DS1r-fg@mail.gmail.com>
	(Ming Lei's message of "Thu, 19 Sep 2013 01:03:31 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:
> On Wed, Sep 18, 2013 at 11:52 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wro=
te:
>
>> Why don't you test it on the device you tested the SG patch with?  I=
 am
>> pretty sure it works just fine using proper ZLP transfer termination=
=2E
>
> I should have planned to test it, but didn't know how to build TCP TS=
O
> to make the whole frame length plus 8 dividable by 1024.

You could test this without enabling TSO and just send IP packets of th=
e
appriopriate size, taking any additional framing into account


Bj=C3=B8rn
