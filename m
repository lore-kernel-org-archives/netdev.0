From: Eric Van Hensbergen <ericvh@gmail.com>
Subject: Re: [patch] 9p: fix min_t() casting
Date: Sun, 16 Jan 2011 10:33:16 -0600
Message-ID: <AANLkTi=vdKX9ruvrdiPgnr59WWrGaP0roFyBvqWW3VSU@mail.gmail.com>
References: <20110115203539.GF2721@bicker>
	<20110115.205208.104051310.davem@davemloft.net>
	<20110116114526.GG2721@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sripathik@in.ibm.com,
	jvrao@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	mohan@in.ibm.com
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35208 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab1APQdR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 11:33:17 -0500
In-Reply-To: <20110116114526.GG2721@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch has already made it upstream via the v9fs pull.  I'll pull
in your fix Dan and request a second pull by Linus.
Thanks for catching this.

      -eric


On Sun, Jan 16, 2011 at 5:45 AM, Dan Carpenter <error27@gmail.com> wrot=
e:
> On Sat, Jan 15, 2011 at 08:52:08PM -0800, David Miller wrote:
>> From: Dan Carpenter <error27@gmail.com>
>> Date: Sat, 15 Jan 2011 23:35:39 +0300
>>
>> > The intent here was to cap the length to USHRT_MAX, but what the
>> > code actually does is it just casts the return from strlen() to
>> > unsigned short and truncates the significant bits away.
>> >
>> > Signed-off-by: Dan Carpenter <error27@gmail.com>
>>
>> If you want me to apply this, it doesn't apply cleanly to net-2.6
>> at all.
>
> Sorry. =A0I screwed up.
>
> This was on top of a patch from M. Mohan Kumar <mohan@in.ibm.com>
> that hasn't hit net-2.6 yet. =A0Mohan wasn't included on the CC
> list because get_maintainer.pl changed and I didn't notice and
> I wasn't careful.
>
> Eric, could Mohan just fix his patch before it gets merged or is it
> better to send these as two patches?
>
> regards,
> dan carpenter
>
> Ps: =A0Mohon the patch is here:
> http://marc.info/?l=3Dlinux-netdev&m=3D129512381528034&w=3D2
>
