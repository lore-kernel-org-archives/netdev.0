From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: discussion questions: SR-IOV, virtualization,
 and bonding
Date: Thu, 02 Aug 2012 16:33:27 -0600
Message-ID: <501B0037.1010804@genband.com>
References: <501AD33E.5090308@genband.com> <17679.1343939453@death.nxdomain>
	<501AFEAD.10001@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <501AFEAD.10001@genband.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 08/02/2012 04:26 PM, Chris Friesen wrote:
> On 08/02/2012 02:30 PM, Jay Vosburgh wrote:

>> The best long term solution is to have a user space API that
>> provides link state input to bonding on a per-slave basis, and then some
>> user space entity can perform whatever link monitoring method is
>> appropriate (e.g., LLDP) and pass the results to bonding.
>
> I think this has potential. This requires a virtual communication
> channel between guest/host if we want the host to be able to influence
> the guest's choice of active link, but I think that's not unreasonable.
>
> Actually, couldn't we do this now? Turn off miimon and arpmon, then just
> have the userspace thing write to /sys/class/net/bondX/bonding/active_slave

Hmm...looks like the bonding code requires either miimon or arpmon.  I 
wonder if setting miimon to INT_MAX might work, at least for some 
bonding modes.

Chris

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
