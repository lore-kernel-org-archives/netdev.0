From: Igor Ryzhov <iryzhov@nfware.com>
Subject: Bonding MAC address
Date: Fri, 28 Oct 2016 14:09:58 +0300
Message-ID: <64717203-D02C-41D0-9D2B-EFEB4CF78146@nfware.com>
Mime-Version: 1.0 (Mac OS X Mail 10.1 \(3251\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35264 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbcJ1LKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 07:10:02 -0400
Received: by mail-lf0-f45.google.com with SMTP id f134so49047083lfg.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 04:10:01 -0700 (PDT)
Received: from [172.20.100.100] (vpn.arccn.ru. [95.182.74.2])
        by smtp.gmail.com with ESMTPSA id u126sm126976lja.12.2016.10.28.04.09.59
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 04:09:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

Studying the bonding driver I found that bonding device doesn't choose a =
new MAC address when the slave which MAC is in use is released.
This is a warning about that - "the permanent HWaddr of slave is still =
in use by bond - set the HWaddr of slave to a different address to avoid =
conflicts".
Why not to choose a new MAC for bonding device? Is it intentional or =
just not implemented?

Best regards,
Igor=
