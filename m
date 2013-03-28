From: Benoit Lourdelet <blourdel@juniper.net>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 20:27:44 +0000
Message-ID: <CD7A6510.796E%blourdel@juniper.net>
References: <874nfwri6o.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Serge Hallyn <serge.hallyn@ubuntu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og129.obsmtp.com ([64.18.2.122]:33482 "EHLO
	exprod7og129.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893Ab3C1UdH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 16:33:07 -0400
Received: from mail121-co1 (localhost [127.0.0.1])	by
 mail121-co1-R.bigfish.com (Postfix) with ESMTP id 888ED7C018B	for
 <netdev@vger.kernel.org.FOPE.CONNECTOR.OVERRIDE>; Thu, 28 Mar 2013 20:27:48
 +0000 (UTC)
In-Reply-To: <874nfwri6o.fsf@xmission.com>
Content-Language: en-US
Content-ID: <F7B12C0413DBD0488A48AC8A5E28E51E@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

I am running simple containers (2 network interfaces, 10MB of RAM, default
routing) and want to test scalability.

Out test platform is a 32x 2Ghz cores x86.

Regards

Benoit

On 27/03/2013 16:11, "Eric W. Biederman" <ebiederm@xmission.com> wrote:

>Benoit Lourdelet <blourdel@juniper.net> writes:
>
>> Hello Serge,
>>
>> I am indeed using Eric patch with lxc.
>>
>> It solves the initial problem of slowness to start around 1600
>> containers.
>
>Good so now we just need a production ready patch for iproute.
>
>> I am now able to start more than  2000 without having new containers
>> slower and slower to start.
>
>May I ask how large a box you are running and how complex your
>containers are.  I am trying to get a feel for how common it is likely
>to be to find people running thousands of containers on a single
>machine.
>
>Eric
>
