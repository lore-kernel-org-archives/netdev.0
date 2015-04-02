From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 00/26] switchdev: spring cleanup
Date: Thu, 2 Apr 2015 08:06:11 +0200
Message-ID: <20150402060611.GA2044@nanopsycho.orion>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
 <20150401114026.GB2025@nanopsycho.orion>
 <CAE4R7bCw3m-ircfA9FiD5+VR3=5vj=cZ7YLTobkXjLoSvYUq_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:36700 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbbDBGGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 02:06:17 -0400
Received: by wgra20 with SMTP id a20so74499428wgr.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 23:06:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bCw3m-ircfA9FiD5+VR3=5vj=cZ7YLTobkXjLoSvYUq_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 01, 2015 at 08:02:48PM CEST, sfeldma@gmail.com wrote:
>On Wed, Apr 1, 2015 at 4:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Apr 01, 2015 at 12:07:36PM CEST, sfeldma@gmail.com wrote:
>>>From: Scott Feldman <sfeldma@gmail.com>
>>>
>>>v2:
>>>
>>>Address review comments:
>>>
>>> - [Jiri] squash a few related patches
>>> - [Roopa] don't remove NETIF_F_HW_SWITCH_OFFLOAD
>>> - [Roopa] address VLAN setlink/dellink
>>> - [Ronen] print warning is attr set revert fails
>>>
>>>Not address:
>>>
>>> - Using something other than "swdev_" prefix
>>
>> I do not understand why this was not addresses. Can you please provide some
>> justification?
>
>1) It was 3AM in the morning, and I didn't want to fight a rename that
>touched 26 patches in the set.
>
>2) I like "swdev_" prefix because it's short and sweet and I don't
>like long-winded symbols when a shorter one will do, so I had little
>motivation for 1)
>
>3) This is one of those labeling exercises where we can't get
>consensus on the name.  So I'm ignoring to get the important stuff in,
>and someone else can sponsor a name change.

So just please avoid the name channge for now. Thanks.
