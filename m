From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 06:39:59 -0400
Message-ID: <5333FFFF.1050005@mojatatu.com>
References: <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com> <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com> <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com> <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com> <20140327065616.GA2845@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Felix Fietkau <nbd@openwrt.org>
To: Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:49426 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbaC0KkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 06:40:02 -0400
Received: by mail-oa0-f49.google.com with SMTP id h16so4065477oag.8
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 03:40:01 -0700 (PDT)
In-Reply-To: <20140327065616.GA2845@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 02:56, Jiri Pirko wrote:
> Wed, Mar 26, 2014 at 11:22:51PM CET, f.fainelli@gmail.com wrote:

>
> I believe that hawing both sw1p3 and eth0 is the correct way of
> modelling this. sw1p3 is instance if switch chip driver representing the
> actual port of a switch. eth0 is an instance of some other ordinary NIC
> driver (8139too is my favorite :))
>
> This model allows to draw the exact picture.
> Also, when you add the described possibility to use iplink to build
> vlans, bridges whatever on the switch ports, it makes perfect sense to
> have this model.
>
> Merging sw1p3 and eth0 would cause a loose of information and confusion.

I think that if eth0 and sw1p3 have different control interfaces i
agree.

Jiri, sorry - didnt respond to your other email on your patch. My
comment was on newlink() interface - i was wondering about why it was
there i.e as in allowing user space to create switch ports.

cheers,
jamal
