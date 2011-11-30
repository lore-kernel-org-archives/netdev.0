From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Wed, 30 Nov 2011 18:48:10 +0000
Message-ID: <1322678890.2762.26.camel@bwh-desktop>
References: <20111109075449.13549.58135.stgit@rhel6.1>
	 <1321575301.2749.51.camel@bwh-desktop>  <4EC5A785.3060108@intel.com>
	 <1321577078.2749.58.camel@bwh-desktop>  <4EC68EBB.3080303@intel.com>
	 <1321638038.2883.28.camel@bwh-desktop>  <4ECA8D50.9080603@intel.com>
	 <1322584544.2684.20.camel@bwh-desktop>
	 <1322587170.2684.26.camel@bwh-desktop>  <4ED6691D.9070606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4ED6691D.9070606@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-30 at 09:34 -0800, Greg Rose wrote:
> On 11/29/2011 9:19 AM, Ben Hutchings wrote:
> > On Tue, 2011-11-29 at 16:35 +0000, Ben Hutchings wrote:
> >>
> >> Maybe I missed something!
[...]
> >> If not, please explain what the new model *is*.
> 
> The new model is to incorporate a VEB into the NIC.  The current model 
> doesn't address any of the requirements of a VEB in the NIC and this 
> proposed set of patches allow us to set MAC filters for the *ports* on 
> the internal NIC VEB.  Consider the PF and each of the VFs as just a 
> port on the VEB.  We need the ability to set L2 filters (MAC, MC and 
> VLAN) for each of the ports on that VEB.  There is no currently 
> supported method for doing this.  So yes, this is a new model although 
> it's a fairly simple one.

Explain precisely how the VEB changes the existing model.  Explain how
the existing MAC filter and VF filter APIs interact with port filters on
the VEB.  Refer to any relevant standards.

(I have really had enough of net driver API proposals where all the
difficult questions are punted to the implementation.  Either
implementations diverge and users and userspace developers are left
horribly confused, or else the second and subsequent implementations
have to follow whatever quirks the first implementation had.  It's an
essential part of the review process that such questions are asked and
answered.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

