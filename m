From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: Face some error after applying commit 7dfa4b414d4(net/mlx4_en:
 Code cleanups in tx path)
Date: Tue, 11 Nov 2014 08:49:06 +0200
Message-ID: <CAJ3xEMjFf7eoTQ7_-YxC7YipY4q7O9HSVQ+UCROk5zEzT4tD1A@mail.gmail.com>
References: <20141108025758.GA13875@richard>
	<CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com>
	<20141110015933.GB6294@richard>
	<1415587574.13896.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141110054010.GA3224@richard>
	<54607095.6070302@mellanox.com>
	<20141111015705.GA8470@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:61637 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbaKKGtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 01:49:07 -0500
Received: by mail-ob0-f170.google.com with SMTP id nt9so7592262obb.15
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 22:49:06 -0800 (PST)
In-Reply-To: <20141111015705.GA8470@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 3:57 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>Please send me the module parameters you used when loading mlx4_core, a
>>full dmesg with both mlx4_core and mlx4_en loading.
>
> The command line I use is:
>         modprobe mlx4_core num_vfs=1 probe_vf=1 port_type_array=2,2
>
> The log I sent in the first mail is the full log, including the CQE error, one
> warning in watchdog, and then print the CQE error periodicly. What else
> message you would like me to capture?
>
> And this error is reported from VF always. After the error, the other network
> interface seems can't function.

Guys, do we have here something which isn't bisectable (i.e the code
doesn't work if you force it to an arbitrary commit within in the
chain) - something which doesn't work as a whole? in case the former,
we will work to do better next times.. in case the latter, Wei, as
Amir asked, please send us full logs when you load/run the driver with
debug level set, for mlx4_core it would be loading with debug_level=1
for mlx4_en you should be able to raise the debug level using ethtool

Or.
