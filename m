From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] USB CDC-Ether - Add ZTE WWAN matches before generic Ethernet
Date: Sat, 19 May 2012 19:30:13 +0200
Message-ID: <87aa14jcyi.fsf@nemi.mork.no>
References: <1337435767-9544-1-git-send-email-ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oliver@neukum.name, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Bird <ajb@spheresystems.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337435767-9544-1-git-send-email-ajb@spheresystems.co.uk>
	(Andrew Bird's message of "Sat, 19 May 2012 14:56:07 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Bird <ajb@spheresystems.co.uk> writes:

> Some ZTE WWAN devices have generic CDC Ether descriptors. Add those
> into the whitelist so that we get FLAG_WWAN on the interface

Are you sure none of these export QMI via the CDC Ether control
interface?  Or are they not Qualcomm devices at all?

As usual, if you see a spurious "CDC: unexpected notification 01" logge=
d
from cdc_ether, then there is reason to examine those closer.  If you
don't see any such messages, then there isn't any QMI there.


Bj=C3=B8rn
