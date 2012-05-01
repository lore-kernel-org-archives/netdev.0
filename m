From: David Miller <davem@davemloft.net>
Subject: Re: e1000e tx queue timeout in 3.3.0 (bisected to BQL
 support for e1000e)
Date: Tue, 01 May 2012 17:49:14 -0400 (EDT)
Message-ID: <20120501.174914.654247970871851432.davem@davemloft.net>
References: <CA+mtBx-K6-O3ea34kmn4LXtx73FqCHF16w7pBSq1fHNN+-DxCA@mail.gmail.com>
	<4F91DB7B.7060601@candelatech.com>
	<4FA05153.1010903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, therbert@google.com
To: greearb@candelatech.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4FA05153.1010903@candelatech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 01 May 2012 14:10:43 -0700

> On 04/20/2012 02:56 PM, Ben Greear wrote:
>> On 04/20/2012 02:21 PM, Tom Herbert wrote:
>>> Thanks John for pointers to those.  Ben, are you running a kernel with
>>> these patches?
>>
>> I just tested this on my e1000e and igb machine.  With these patches,
>> I can no longer reproduce the problem.
>>
>> So, please make sure those are queued up for 3.3 stable!
> 
> Dave:  I think these patches below should go to 3.3 stable.
> 
> They are not queued for stable yet as far as I can tell.

I let the Intel developers handle -stable submissions for their
drivers.

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
