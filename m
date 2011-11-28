From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v4 PATCH 2/2] NETFILTER userspace part for target
	HMARK
Date: Mon, 28 Nov 2011 09:37:38 +0100 (CET)
Message-ID: <hr62jai.f4f5223b83b31ae9b337edbf22b93bdf@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "=?utf-8?Q?Hans_Schillstr=C3=B6m?=" <hans.schillstrom@ericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jan Engelhardt" <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>+Parameters:
>>>>+For all masks default is all "1:s", to disable a field use mask 0
>>>>+For IPv6 it's just the last 32 bits that is included in the hash
>>>
>>>Why limit IPv6 to 32?
>>
>>Performance, and the gain of adding another 192 bits to jhash ain't much.
>>However there is some cases when it hurts, i.e. when you can't mask of an subnet
>>I'm not sure it it's a problem or not... 
>
>I was thinking about the case where two particular hosts have the same 
>trailing 32 bits in their source address. For example, assuming IPv6 
>starts to take a stronghold in the real world and home customers start 
>assigning <myprefix>::1 to the little home server (i.e. the PPP 
>endpoint) of theirs for remote login.

Yes that's a good point,  I will have a look at this and see haw to speed-up the IPv6 calc.

btw
parsing by using xoption.c  is there a way to allow both hex format and mask length ?
i.e. --smask 0xffff0000   or  --smask /16

/Hans

