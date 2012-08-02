From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: discussion questions: SR-IOV, virtualization,
	and bonding
Date: Thu, 02 Aug 2012 16:36:42 -0700
Message-ID: <20833.1343950602@death.nxdomain>
References: <501AD33E.5090308@genband.com> <17679.1343939453@death.nxdomain>
	<501AFEAD.10001@genband.com> <501B0037.1010804@genband.com>
	<20421.1343948491@death.nxdomain> <501B0A10.8030703@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <501B0A10.8030703@genband.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Chris Friesen <chris.friesen@genband.com> wrote:

>On 08/02/2012 05:01 PM, Jay Vosburgh wrote:
>> Chris Friesen<chris.friesen@genband.com>  wrote:
>
>> 	Still, though, isn't "influence the guest's choice" pretty much
>> satisified by having the VF interface go carrier down in the guest when
>> the host wants it to?  Or are you thinking about more fine grained than
>> that?
>
>That was the first thing we started looking at.
>
>It would actually be better technically (since it would use the
>back-channel between PF and VFs rather than needing an explicit virtual
>network link between host/guest) but it would require work in all the
>PF/VF drivers.  We'd need to get support from all the driver maintainers.

	It might also be better (for a different definition of "better")
to use the virtual network link and do more functionality in a generic
user space piece that's not in the kernel and wouldn't require special
driver support.  Either way, I imagine there's going to have to be some
sort of message passing going on.

>The main advantage of doing it in bonding is that we'd only need to modify
>the code in one place.

	As long as it works with VLANs bonded together; that seems to be
more common these days.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


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
