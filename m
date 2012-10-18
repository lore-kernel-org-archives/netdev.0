From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v1] net/core: support runtime PM on net_device
Date: Thu, 18 Oct 2012 19:01:06 +0800
Message-ID: <CACVXFVPu1m3CJaFavW9eaU3Z850q+x1N_Yo7tri1UTFpgfYVXQ@mail.gmail.com>
References: <1350548469-1267-1-git-send-email-ming.lei@canonical.com>
	<8762689o9u.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55608 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755595Ab2JRLBI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 07:01:08 -0400
In-Reply-To: <8762689o9u.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 18, 2012 at 4:29 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <ming.lei@canonical.com> writes:
>
>> In ioctl path on net_device, the physical deivce is often
>> touched, but the physical device may have been put into runtime
>> suspend state already, so cause some utilitis(ifconfig, ethtool,
>> ...) to return failure in this situation.
>
> I have to as the stupid questions again, sorry...
>
> Just wondering, isn't that really a driver problem?  The driver will

It is or not, :-)

> know whether or not hardware access is required, and should wake up t=
he

The netcore knows that first,  doesn't it=EF=BC=9F

> device if necessary.  Unless I misunderstand something here, this see=
ms
> like papering over driver bugs?

Suppose it is driver bug, and basically most network drivers don't cons=
ider
that, and we can fix that in netcore generally, so why bother all drive=
rs to do
that?


Thanks,
--
Ming Lei
