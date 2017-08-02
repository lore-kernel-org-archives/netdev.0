From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [PATCH RFC, iproute2] tc/mirred: Extend the mirred/redirect
 action to accept additional traffic class parameter
Date: Wed, 2 Aug 2017 11:28:41 -0700
Message-ID: <8ff50a21-b17f-51da-6746-70a9eda84296@intel.com>
References: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
 <20170731205133.5e58e47c@xeon-e3>
 <063D6719AE5E284EB5DD2968C1650D6DD00483C5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
        "kiran.patil@intel.com" <kiran.patil@intel.com>,
        "sridhar.samudrala@intel.com" <sridhar.samudrala@intel.com>,
        "mitch.a.williams@intel.com" <mitch.a.williams@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "neerav.parikh@intel.com" <neerav.parikh@intel.com>,
        "carolyn.wyborny@intel.com" <carolyn.wyborny@intel.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: David Laight <David.Laight@ACULAB.COM>,
        'Stephen Hemminger' <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:1990 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752035AbdHBS2m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 14:28:42 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00483C5@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/2017 8:12 AM, David Laight wrote:
> From: Stephen Hemminger
>> Sent: 01 August 2017 04:52
>> On Mon, 31 Jul 2017 17:40:50 -0700
>> Amritha Nambiar <amritha.nambiar@intel.com> wrote:
>> The concept is fine, bu t the code looks different than the rest which
>> is never a good sign.
>>
>>
>>> +				if ((argc > 0) && (matches(*argv, "tc") == 0)) {
>>
>> Extra () are unnecessary in compound conditional.
>>
>>> +					tc = atoi(*argv);
>>
>> Prefer using strtoul since it has better error handling than atoi()
>>
>>> +					argc--;
>>> +					argv++;
>>> +				}
>>
>>
>> Use NEXT_ARG() construct like rest of the code.
> 
> Why bother faffing about with argc at all?
> The argument list terminates when *argv == NULL.
> 

I'll submit the next version with these fixes.

> 	David
> 
