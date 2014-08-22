From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic switch devices
 support
Date: Fri, 22 Aug 2014 14:56:55 +0200
Message-ID: <20140822125655.GB1916@nanopsycho.orion>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-4-git-send-email-jiri@resnulli.us>
 <CAGVrzcYtnpcP4pfCJ0GSya01LTk0WwbSV1f+voF2K=S5CR3Arg@mail.gmail.com>
 <53F73A9C.4000209@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>, tgraf <tgraf@suug.ch>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	dev <dev@openvswitch.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:48616 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756108AbaHVM47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 08:56:59 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so10144560wiv.17
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 05:56:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53F73A9C.4000209@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 22, 2014 at 02:42:04PM CEST, jhs@mojatatu.com wrote:
>On 08/21/14 13:05, Florian Fainelli wrote:
>>2014-08-21 9:18 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
>>>The goal of this is to provide a possibility to suport various switch
>>>chips. Drivers should implement relevant ndos to do so. Now there is a
>>>couple of ndos defines:
>>>- for getting physical switch id is in place.
>>>- for work with flows.
>>>
>>>Note that user can use random port netdevice to access the switch.
>>
>>I read through this patch set, and I still think that DSA is the
>>generic switch infrastructure we already have because it does provide
>>the following:
>>
>>- taking a generic platform data structure (C struct or Device Tree),
>>validate, parse it and map it to internal kernel structures
>>- instantiate per-port network devices based on the configuration data provided
>>- delegate netdev_ops to the switch driver and/or the CPU NIC when relevant
>>- provide support for hooking RX and TX traffic coming from the CPU NIC
>>
>>I would rather we build on the existing DSA infrastructure and add the
>>flow-related netdev_ops rather than having the two remain in
>>disconnect while flow-oriented switches driver get progressively
>>added. I guess I should take a closer look at the rocker driver to see
>>how hard would that be for you.
>>
>>What do you think?
>
>
>I thought we had concluded that DSA was a good path forward?  Or maybe at
>this stage we need to have several alternative approaches
>and we eventually converge?

That is true. I'm still unsure how to fit this on to DSA or how to change DSA
the way this fits. This is my quest now. Will report back in a week or so.

>
>cheers,
>jamal
>
>
