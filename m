From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [PATCH RFC, iproute2] tc/mirred: Extend the mirred/redirect
 action to accept additional traffic class parameter
Date: Wed, 2 Aug 2017 11:58:36 -0700
Message-ID: <c575cc71-f61b-6b22-de01-5d559f740bf6@intel.com>
References: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
 <CAJieiUi=W1jJBkMXTnFYL=Cw4ZWCv5zeg1vtveW5TyfJ2noe9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        kiran.patil@intel.com,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        mitch.a.williams@intel.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        neerav.parikh@intel.com, carolyn.wyborny@intel.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29821 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752477AbdHBS6i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 14:58:38 -0400
In-Reply-To: <CAJieiUi=W1jJBkMXTnFYL=Cw4ZWCv5zeg1vtveW5TyfJ2noe9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/2017 11:41 AM, Roopa Prabhu wrote:
> On Mon, Jul 31, 2017 at 5:40 PM, Amritha Nambiar
> <amritha.nambiar@intel.com> wrote:
>> The Mirred/redirect action is extended to accept a traffic
>> class on the device in addition to the device's ifindex.
>>
>> Usage: mirred <DIRECTION> <ACTION> <dev DEVICENAME> <tc TC_INDEX>
>>
>> Example:
>> # tc qdisc add dev eth0 ingress
>>
>> # tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
>>   dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
>>   indev eth0 action mirred ingress redirect dev eth0 tc 1
> 
> 
> Can we call the new parameter tclass or something else ?.
> with this 'tc' appears twice in the command :)
> 

Sounds right. I was already thinking of alternatives like 'tcqgroup',
'qgroup' and now we have 'tclass'.
