From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Fri, 9 Apr 2010 11:09:48 -0700
Message-ID: <p2w97949e3e1004091109gc2968c75tf181904f5a627043@mail.gmail.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com> <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
	<w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com>
	<1270755356.5055.23.camel@achroite.uk.solarflarecom.com> <j2r97949e3e1004081543h6258125dm60083556ff28fa88@mail.gmail.com>
	<4BBE78E2.2000709@garzik.org> <x2o97949e3e1004090943o4b6b29e5pd261e2cb4c7f421d@mail.gmail.com>
	<4BBF5D72.8010603@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:6212 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753359Ab0DISKN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 14:10:13 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o39IAAK5021887
	for <netdev@vger.kernel.org>; Fri, 9 Apr 2010 11:10:10 -0700
Received: from gwb1 (gwb1.prod.google.com [10.200.2.1])
	by wpaz1.hot.corp.google.com with ESMTP id o39IA9rN011959
	for <netdev@vger.kernel.org>; Fri, 9 Apr 2010 11:10:09 -0700
Received: by gwb1 with SMTP id 1so133032gwb.3
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 11:10:09 -0700 (PDT)
In-Reply-To: <4BBF5D72.8010603@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 9, 2010 at 10:01 AM, Jeff Garzik <jeff@garzik.org> wrote:
> On 04/09/2010 12:43 PM, Laurent Chavey wrote:
>>
>> isn't the existing ETHTOOL_TEST ioctl use for something like self te=
st ?
>>
>> the intent of this patch is to enable a mode whereby one could run
>> netperf / iperf and other application =A0and have the packets sent a=
nd
>> received by the driver.
>
> I said "ethtool flags interface", which is ETHTOOL_[GS]FLAGS.
>
> ethtool private flags interface would also work, ETHTOOL_[GS]PFLAGS.
>
> Both are interfaces enabling user setting/clearing of 32 on/off switc=
hes
> (bits).

agree, no need to patch

>
> =A0 =A0 =A0 =A0Jeff
>
>
>
>
>
