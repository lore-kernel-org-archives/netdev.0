From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Tue, 4 May 2010 17:18:57 -0700
Message-ID: <20100505001857.GQ8323@vmware.com>
References: <20100504230225.GP8323@vmware.com>
 <20100504170531.1e7122da@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100504170531.1e7122da@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The purpose of this email is to introduce the architecture and the design principles. The overall project involves more than just changes to vmxnet3 driver and hence we though an overview email would be better. Once people agree to the design in general we intend to provide the code changes to the vmxnet3 driver.

The architecture supports more than Intel NICs. We started the project with Intel but plan to support all major IHVs including Broadcom, Qlogic, Emulex and others through a certification program. The architecture works on VMware ESX server only as it requires significant support from the hypervisor. Also, the vmxnet3 driver works on VMware platform only. AFAICT Xen has a different model for supporting SR-IOV devices and allowing live migration and the document briefly talks about it (paragraph 6).

Thanks,

-pankaj


On Tue, May 04, 2010 at 05:05:31PM -0700, Stephen Hemminger wrote:
> Date: Tue, 4 May 2010 17:05:31 -0700
> From: Stephen Hemminger <shemminger@vyatta.com>
> To: Pankaj Thakkar <pthakkar@vmware.com>
> CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
> 	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
> 	"virtualization@lists.linux-foundation.org"
>  <virtualization@lists.linux-foundation.org>,
> 	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
> 	Shreyas Bhatewara <sbhatewara@vmware.com>
> Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
> 
> On Tue, 4 May 2010 16:02:25 -0700
> Pankaj Thakkar <pthakkar@vmware.com> wrote:
> 
> > Device passthrough technology allows a guest to bypass the hypervisor and drive
> > the underlying physical device. VMware has been exploring various ways to
> > deliver this technology to users in a manner which is easy to adopt. In this
> > process we have prepared an architecture along with Intel - NPA (Network Plugin
> > Architecture). NPA allows the guest to use the virtualized NIC vmxnet3 to
> > passthrough to a number of physical NICs which support it. The document below
> > provides an overview of NPA.
> > 
> > We intend to upgrade the upstreamed vmxnet3 driver to implement NPA so that
> > Linux users can exploit the benefits provided by passthrough devices in a
> > seamless manner while retaining the benefits of virtualization. The document
> > below tries to answer most of the questions which we anticipated. Please let us
> > know your comments and queries.
> > 
> > Thank you.
> > 
> > Signed-off-by: Pankaj Thakkar <pthakkar@vmware.com>
> 
> 
> Code please. Also, it has to work for all architectures not just VMware and
> Intel.
