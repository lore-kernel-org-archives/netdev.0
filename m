From: Clemens Ladisch <clemens@ladisch.de>
Subject: Re: [PATCH v2] add stealth mode
Date: Tue, 07 Jul 2015 09:01:23 +0200
Message-ID: <559B7943.3070807@ladisch.de>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com> <21611.1436179798@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu, Matteo Croce <matteo@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21611.1436179798@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valdis.Kletnieks@vt.edu wrote:
> On Thu, 02 Jul 2015 10:56:01 +0200, Matteo Croce said:
>> Add option to disable any reply not related to a listening socket
>
> 2) You *do* realize that this isn't anywhere near sufficient in order
> to actually make your machine "invisible", right?  (Hint: What *other*
> packets can be sent to a machine to provoke a response?)

Even worse: if you want to pretend that the entire machine is "not there",
you must make the router in front on you reply with an ICMP "destination
unreachable" message.


Regards,
Clemens
