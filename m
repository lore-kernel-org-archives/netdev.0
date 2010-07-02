From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Fri, 02 Jul 2010 08:37:34 +0200
Message-ID: <4C2D892E.5030905@redhat.com>
References: <4C2B0614.9040004@redhat.com>
	<201006300959.37145.leedom@chelsio.com>
	<4C2C378D.4090806@redhat.com>
	<201007011012.48236.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <201007011012.48236.leedom@chelsio.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01.07.2010 19:12, Casey Leedom wrote:
> | From: Stefan Assmann <sassmann@redhat.com>
> | Date: Wednesday, June 30, 2010 11:37 pm
> | 
> | You're correct, the problem shouldn't occur with cxgb4vf and therefore
> | this change shouldn't be necessary. However we might consider a
> | consistent naming scheme for VFs in all drivers. But I don't have a
> | strong opinion about this, either way would be fine by me.
> 
>   Sorry, I hadn't meant to imply any criticism of your naming proposal.  I was 
> just trying to clarify when/where such a scheme might be necessary.

Sure, that's the reason why we're discussing this here.

> 
>   On the naming proposal itself, it strikes me that the most common use of PCI-E 
> SR-IOV Virtual Functions will be to export them to KVM Virtual Machines via PCI 
> "Pass Through."  So there shouldn't be any naming conflict there, right?  Or is 
> it the same scenario you described before: that the VF NIC device might be found 
> before the normal "eth0", etc. withing the Virtual Machine?

I haven't had a scenario were passing multiple VF NICs to the guest was
necessary. In theory it might happen there as well, if you have multiple
NICs (with persistent and random MACs) in the guest. But usually you
just have a single VF inside the guest and then you're fine.

The scenario that I'm targeting is on the host side mostly.

  Stefan
--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
