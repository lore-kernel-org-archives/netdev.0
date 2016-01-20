From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: mlx4 fails ("go bit not cleared") without MSI
Date: Wed, 20 Jan 2016 11:00:49 -0600
Message-ID: <CAErSpo7RKHE-vopDYh8P83Wb_5_-Fj8SSn7_Z=9cqYgBOejpxw@mail.gmail.com>
References: <HE1PR05MB1418EEAC4F82E2ECF9AC0920CEC10@HE1PR05MB1418.eurprd05.prod.outlook.com>
 <CAErSpo5PsAvix815Z1Ge5-UTx5z-0m5W2p4F9J=s8AB03=C+Dw@mail.gmail.com> <HE1PR05MB1418CCA550156D65E76B2544CEC20@HE1PR05MB1418.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "helgaas@kernel.org" <helgaas@kernel.org>,
	Majd Dibbiny <majd@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	"Or Gerlitz (gerlitz.or@gmail.com)" <gerlitz.or@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yishai Hadas <yishaih@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36782 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbcATRBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 12:01:10 -0500
Received: by mail-yk0-f178.google.com with SMTP id v14so16777515ykd.3
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 09:01:09 -0800 (PST)
In-Reply-To: <HE1PR05MB1418CCA550156D65E76B2544CEC20@HE1PR05MB1418.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 3:42 AM, Yishai Hadas <yishaih@mellanox.com> wrote:
>> From: Bjorn Helgaas [mailto:bhelgaas@google.com]
>> I assume you're tried booting with "pci=nomsi" or "mlx_core.msi_x=0"
>> and it works for you?  Note that my board might be an internal design,
>> not a Mellanox board, so if it works for you, we can probably just
>> ignore this as being an artifact of the internal design.
>
> Yes, it works for me (module parameter msi_x=0), as you pointed out above
> you are not using Mellanox board but some internal design and
> it might be some artifact of.

OK, let's assume that's the case.  I haven't seen the actual board, so
I can't be certain what I'm using.  Thanks for checking into it.

Bjorn
