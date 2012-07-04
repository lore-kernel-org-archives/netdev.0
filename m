From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Using interface number probing for usbnet drivers before 3.6-rc1? (was: Re: [PATCH net] net: qmi_wwan: fix Gobi device probing)
Date: Wed, 04 Jul 2012 13:19:35 +0200
Message-ID: <87mx3flqns.fsf_-_@nemi.mork.no>
References: <1340282758-18085-1-git-send-email-bjorn@mork.no>
	<20120622.171735.637204872051168180.davem@davemloft.net>
	<87y5neidk1.fsf@nemi.mork.no>
	<20120623.023749.1066357959466872561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37700 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932541Ab2GDLTs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 07:19:48 -0400
In-Reply-To: <20120623.023749.1066357959466872561.davem@davemloft.net> (David
	Miller's message of "Sat, 23 Jun 2012 02:37:49 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Sat, 23 Jun 2012 11:26:54 +0200
>
>> Is waiting for 3.6-rc1 the best alternative, or is cherry-picking th=
em
>> an option?
>
> I'm extremely reluctant to have a dependency on another tree.
>
> The USB tree, on the other hand, could pull the net-next tree
> in so you can continue your dependent work there.

Hello Greg,

I know I said I would be more careful about cross-tree dependencies, bu=
t
here I am again...

The context is: How should I proceed with interface number based probin=
g
for usbnet drivers, in particular qmi_wwan which already has a few
patches in net-next?

I see two possible remaining options:

 1) you pull the net-next changes into usb-next so that I can do the
    work against usb-next now, or
 2) I wait for 3.6-rc1 and do the work against the net tree after
    3.6-rc1 is merged there

I have decided to go for option #2 unless either of you have other
preferences, as I believe that is going to cause the least work and
merge trouble for you both.

The changes are mostly device IDs, but I am also going to rip out all
the whitelist probing logic becoming redundant. This is a single driver
and pretty obvious low risk though, so I believe it is appropriate for
an -rc2.

But please let me know if I'm on the wrong track here.


Bj=C3=B8rn
