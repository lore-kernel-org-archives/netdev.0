From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 00/26] switchdev: spring cleanup
Date: Wed, 1 Apr 2015 11:02:48 -0700
Message-ID: <CAE4R7bCw3m-ircfA9FiD5+VR3=5vj=cZ7YLTobkXjLoSvYUq_w@mail.gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
	<20150401114026.GB2025@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:34411 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbbDASCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 14:02:49 -0400
Received: by qcay5 with SMTP id y5so47889081qca.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 11:02:49 -0700 (PDT)
In-Reply-To: <20150401114026.GB2025@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 1, 2015 at 4:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Apr 01, 2015 at 12:07:36PM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>v2:
>>
>>Address review comments:
>>
>> - [Jiri] squash a few related patches
>> - [Roopa] don't remove NETIF_F_HW_SWITCH_OFFLOAD
>> - [Roopa] address VLAN setlink/dellink
>> - [Ronen] print warning is attr set revert fails
>>
>>Not address:
>>
>> - Using something other than "swdev_" prefix
>
> I do not understand why this was not addresses. Can you please provide some
> justification?

1) It was 3AM in the morning, and I didn't want to fight a rename that
touched 26 patches in the set.

2) I like "swdev_" prefix because it's short and sweet and I don't
like long-winded symbols when a shorter one will do, so I had little
motivation for 1)

3) This is one of those labeling exercises where we can't get
consensus on the name.  So I'm ignoring to get the important stuff in,
and someone else can sponsor a name change.
