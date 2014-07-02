From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it occupies
 too many slots
Date: Wed, 2 Jul 2014 14:12:14 +0100
Message-ID: <53B4052E.10008@citrix.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com> <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com> <20140516131145.GK18551@zion.uk.xensource.com> <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com> <20140516143653.GL18551@zion.uk.xensource.com> <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com> <20140516153452.GM18551@zion.uk.xensource.com> <53763CD1.6060500@citrix.com> <53883C18.2050708@canonical.com> <53887472.1000304@citrix.com> <53B3F9BF.603@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Stefan Bader <stefan.bader@canonical.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:36504 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaGBNMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 09:12:17 -0400
In-Reply-To: <53B3F9BF.603@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Yes, it lost traction recently a little bit. The latest idea is to use 
the skb segmenting code in netfront to slice up the skb until it becomes 
a set of skbs which can fit through the ring. But to test that out I 
need to make pktgen work with TCP, that's where this got stopped.

Zoli


On 02/07/14 13:23, Stefan Bader wrote:
> On 30.05.2014 14:07, Zoltan Kiss wrote:
>> On 30/05/14 09:06, Stefan Bader wrote:
>>> On 16.05.2014 18:29, Zoltan Kiss wrote:
>>>> On 16/05/14 16:34, Wei Liu wrote:
>>>>> On Fri, May 16, 2014 at 08:22:19AM -0700, Eric Dumazet wrote:
>>>>>> On Fri, 2014-05-16 at 15:36 +0100, Wei Liu wrote:
>>>>>>> On Fri, May 16, 2014 at 07:21:08AM -0700, Eric Dumazet wrote:
>>>>>>>> On Fri, 2014-05-16 at 14:11 +0100, Wei Liu wrote:
>
> Hi Zoltan,
>
> I lost a bit track about this. I think I saw some summary about brainstorming
> something similar but for the backend from you (not sure). I think during last
> Xen Hackathon. I cannot remember that got to some solution on the netfront side.
> Do I miss something?
>
> -Stefan
>>
>> Regads,
>>
>> Zoltan
