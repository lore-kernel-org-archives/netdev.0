From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC driver:
 vmxnet3
Date: Tue, 29 Sep 2009 09:37:59 -0700
Message-ID: <89E2752CFA8EC044846EB849981913410173CDFD23@EXCH-MBX-4.vmware.com>
References: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
 <20090928.170821.124026517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"anthony@codemonkey.ws" <anthony@codemonkey.ws>,
	"chrisw@sous-sol.org" <chrisw@sous-sol.org>,
	"greg@kroah.com" <greg@kroah.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752647AbZI2Qh7@vger.kernel.org>
In-Reply-To: <20090928.170821.124026517.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, September 28, 2009 5:08 PM
> To: Shreyas Bhatewara
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org;
> shemminger@linux-foundation.org; jgarzik@pobox.com;
> anthony@codemonkey.ws; chrisw@sous-sol.org; greg@kroah.com; akpm@linux-
> foundation.org; virtualization@lists.linux-foundation.org; pv-
> drivers@vmware.com
> Subject: Re: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC
> driver: vmxnet3
> 
> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Mon, 28 Sep 2009 16:56:45 -0700
> 
> > +       uint32_t rxdIdx:12;    /* Index of the RxDesc */
> 
> Don't use uint32_t et al. sized types, use "u32" and friends
> throughout.

Sure, I will fix that.

->Shreyas
