From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v1] net/core: support runtime PM on net_device
Date: Thu, 18 Oct 2012 13:40:27 +0200
Message-ID: <87obk080us.fsf@nemi.mork.no>
References: <1350548469-1267-1-git-send-email-ming.lei@canonical.com>
	<8762689o9u.fsf@nemi.mork.no>
	<CACVXFVPu1m3CJaFavW9eaU3Z850q+x1N_Yo7tri1UTFpgfYVXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51048 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717Ab2JRLkp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 07:40:45 -0400
In-Reply-To: <CACVXFVPu1m3CJaFavW9eaU3Z850q+x1N_Yo7tri1UTFpgfYVXQ@mail.gmail.com>
	(Ming Lei's message of "Thu, 18 Oct 2012 19:01:06 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:
> On Thu, Oct 18, 2012 at 4:29 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>> Ming Lei <ming.lei@canonical.com> writes:
>>
>>> In ioctl path on net_device, the physical deivce is often
>>> touched, but the physical device may have been put into runtime
>>> suspend state already, so cause some utilitis(ifconfig, ethtool,
>>> ...) to return failure in this situation.
>>
>> I have to as the stupid questions again, sorry...
>>
>> Just wondering, isn't that really a driver problem?  The driver will
>
> It is or not, :-)
>
>> know whether or not hardware access is required, and should wake up =
the
>
> The netcore knows that first,  doesn't it=EF=BC=9F

Really? Does netcore know which ioctls the driver can handle without
waking the device?  You can of course do an educated guess, but I reall=
y
hate guesswork if there is a real answer somewhere else...

>> device if necessary.  Unless I misunderstand something here, this se=
ems
>> like papering over driver bugs?
>
> Suppose it is driver bug, and basically most network drivers don't co=
nsider
> that, and we can fix that in netcore generally, so why bother all dri=
vers to do
> that?

Because bugs are supposed to be fixed and not hidden?

Note that I am not claiming this is a bug.  That is still an open
question as far as I can see.



Bj=C3=B8rn
