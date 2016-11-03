From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH RFC 0/2] ethtool: Add actual port speed reporting
Date: Thu, 3 Nov 2016 10:09:08 -0700
Message-ID: <fce609ee-3dfd-b71b-b9d9-528d80d18081@hpe.com>
References: <1478100914-23610-1-git-send-email-galp@mellanox.com>
 <BL2PR07MB23069B0DB17B981AA43775B18DA00@BL2PR07MB2306.namprd07.prod.outlook.com>
 <7a681afa-a5fa-3039-873c-d13617484cc9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Decotigny <decot@googlers.com>,
        Ben Hutchings <ben@decadent.org.uk>
To: Gal Pressman <galp.dev@gmail.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        Gal Pressman <galp@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "John W. Linville" <linville@tuxdriver.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hpe.com ([15.241.140.73]:45217 "EHLO
        g4t3427.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759000AbcKCRJM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:09:12 -0400
In-Reply-To: <7a681afa-a5fa-3039-873c-d13617484cc9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> And besides, one can argue that in the SR-IOV scenario the VF has no business
>> knowing the physical port speed.
>>
>
> Good point, but there are more use-cases we should consider.
> For example, when using Multi-Host/Flex-10/Multi-PF each PF should
> be able to query both physical port speed and actual speed.

Despite my email address, I'm not fully versed on VC/Flex, but I have 
always been under the impression that the flexnics created were, 
conceptually, "distinct" NICs considered independently of the physical 
port over which they operated.  Tossing another worm or three into the 
can, while "back in the day" (when some of the first ethtool changes to 
report speeds other than the "normal" ones went in) the speed of a 
flexnic was fixed, today, it can actually operate in a range.  From a 
minimum guarantee to an "if there is bandwidth available" cap.

rick jones
