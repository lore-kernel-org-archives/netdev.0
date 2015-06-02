From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 0/3] DSA and Marvell 88E6352 802.1q support
Date: Mon, 01 Jun 2015 17:14:33 -0700
Message-ID: <556CF569.2050408@gmail.com>
References: <556723FF.7030606@roeck-us.net> <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com> <CAE4R7bA43Jg5e+DSySvG4X2ka0CXEk9K6eVv5fdN37EcLBoF_A@mail.gmail.com> <5568EB55.9090700@roeck-us.net> <CAE4R7bBfyN-R9DsPwTz4HMA-oimqKH73qEcxi4zfkM-7y2sgYg@mail.gmail.com> <556B3F93.5020701@roeck-us.net> <CAE4R7bBavvmLS=Ra66eeEonZ7x4Syq_PQJ928Ry-f3O9yA9yRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36685 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbbFBAPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 20:15:33 -0400
Received: by pdjm12 with SMTP id m12so36551187pdj.3
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 17:15:32 -0700 (PDT)
In-Reply-To: <CAE4R7bBavvmLS=Ra66eeEonZ7x4Syq_PQJ928Ry-f3O9yA9yRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/05/15 14:21, Scott Feldman wrote:
>> Hi Scott,
>>
>> If I understand you correctly, that means we would expect users to
>> use bridge commands even on non-bridged dsa ports. I don't think we can
>> make this kind of assumption. Users will expect configure VLANs on
>> non-bridge ports as they would normally configure VLANs, using the 8021q
>> module.
>>
>> So I guess we'll have to support the ndo ops for dsa.
> 
> I think that's fine.  There is flexibility here.  Using the "bridge"
> command for non-bridged ports is a little weird.  You'll still need
> setlink to get the PVID/untagged flags, for the bridged-port cases, as
> was done in the original RFC patch.
> 
> I wonder if a new command "vlan" for the iproute2 pkg would be useful?
>  It would absorb the vconfig command options, making vconfig obsolete.
> Some of vconfig functionality is already in iproute2, for example "ip
> link add link ... type vlan ..."

I would definitively like to see that. Right now, this is a little
confusing for users to realize that using bridge + VLAN filtering is a
lot more powerful to configure a switch rather than using
vconfig/iproute add type vlan.
-- 
Florian
