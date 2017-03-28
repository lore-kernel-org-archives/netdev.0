From: "Von Dentz, Luiz" <luiz.von.dentz@intel.com>
Subject: Re: [PATCH] 6lowpan: set peer_addr correctly again
Date: Tue, 28 Mar 2017 16:42:50 +0300
Message-ID: <CACumGO+QvuyDg21yogaUn1WCHv2S3=_DXD+My0Q6ANYE1NYKzg@mail.gmail.com>
References: <20170328132935.382216-1-arnd@arndb.de> <368A8A18-0B9B-4733-86EF-D44C8E9CAE36@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Arnd Bergmann <arnd@arndb.de>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        Eric Dumazet <edumazet@google.com>,
        Patrik Flykt <patrik.flykt@linux.intel.com>,
        Alexander Aring <aar@pengutronix.de>,
        Glenn Ruben Bakke <glennrubenbakke@nordicsemi.no>,
        "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34422 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933116AbdC1NnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:43:03 -0400
Received: by mail-lf0-f41.google.com with SMTP id z15so38478115lfd.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 06:42:56 -0700 (PDT)
In-Reply-To: <368A8A18-0B9B-4733-86EF-D44C8E9CAE36@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel,

On Tue, Mar 28, 2017 at 4:37 PM, Marcel Holtmann <marcel@holtmann.org> wrot=
e:
> Hi Arnd,
>
>> A bugfix accidentally changed one line to return the peer_addr
>> from setup_header, causing it to become unused:
>>
>> net/bluetooth/6lowpan.c: In function 'setup_header':
>> net/bluetooth/6lowpan.c:402:14: error: parameter 'peer_addr' set but not=
 used [-Werror=3Dunused-but-set-parameter]
>>
>> The only user of the variable is a subsequent printk(), and
>> it is not otherwise initialized, so reverting the changed line
>> looks like the right fix.
>>
>> Fixes: fb6f2f606ce8 ("6lowpan: Fix IID format for Bluetooth")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>> net/bluetooth/6lowpan.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>
> I took Colin=E2=80=99s patch since it showed up first in my inbox.

Thanks, I might be missing something since the error doesn't show up for me=
:

  CC [M]  net/bluetooth/6lowpan.o
  LD [M]  net/bluetooth/bluetooth_6lowpan.o
