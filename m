From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH net-next 0/4] switchdev: avoid duplicate packet forwarding
Date: Wed, 17 Jun 2015 06:23:41 -0400
Message-ID: <55814AAD.1090108@mojatatu.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com> <20150615.162551.805611215439524288.davem@davemloft.net> <20150616060427.GA2135@nanopsycho.orion> <CAE4R7bDEw0JVkwagps1eBVGuZuK58eEfTX+0GU-2U1UKGCYyKQ@mail.gmail.com> <20150616211147.GB2135@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	davidch <davidch@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37641 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbbFQKXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 06:23:49 -0400
Received: by igbsb11 with SMTP id sb11so33494328igb.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 03:23:48 -0700 (PDT)
In-Reply-To: <20150616211147.GB2135@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/15 17:11, Jiri Pirko wrote:
> Tue, Jun 16, 2015 at 06:47:47PM CEST, sfeldma@gmail.com wrote:
>> On Mon, Jun 15, 2015 at 11:04 PM, Jiri Pirko <jiri@resnulli.us> wrote:

>> So what we need is a unique mark for device ports within a fwding
>> group, such as a bridge.
>
> Yep, have a group of netdevs, pick one of them and use it's ifindex for
> the whole group.
>

Have you look at the netdev group attribute?
Typically user space sets the value and then you can perform operations
per group of netdevs. You could argue that the field is for user space
to dictate in some policy therefore may be slightly unsuited
for what you are after maybe?

cheers,
jamal
