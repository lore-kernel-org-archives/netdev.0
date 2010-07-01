From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Thu, 1 Jul 2010 10:12:47 -0700
Message-ID: <201007011012.48236.leedom@chelsio.com>
References: <4C2B0614.9040004@redhat.com>
	<201006300959.37145.leedom@chelsio.com>
	<4C2C378D.4090806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4C2C378D.4090806@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

| From: Stefan Assmann <sassmann@redhat.com>
| Date: Wednesday, June 30, 2010 11:37 pm
| 
| You're correct, the problem shouldn't occur with cxgb4vf and therefore
| this change shouldn't be necessary. However we might consider a
| consistent naming scheme for VFs in all drivers. But I don't have a
| strong opinion about this, either way would be fine by me.

  Sorry, I hadn't meant to imply any criticism of your naming proposal.  I was 
just trying to clarify when/where such a scheme might be necessary.

  On the naming proposal itself, it strikes me that the most common use of PCI-E 
SR-IOV Virtual Functions will be to export them to KVM Virtual Machines via PCI 
"Pass Through."  So there shouldn't be any naming conflict there, right?  Or is 
it the same scenario you described before: that the VF NIC device might be found 
before the normal "eth0", etc. withing the Virtual Machine?

  In any case, I don't really have any feelings one way or the other about 
interface naming.  As I mentioned before, the cxgb4vf driver will end up with 
persistent MAC addresses so all the normal interface management stuff will work 
normally (naming, DHCP, etc.)

Casey

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
