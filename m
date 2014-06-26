From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] cxgb4: use dev_port to identify ports
Date: Thu, 26 Jun 2014 09:37:09 -0300
Message-ID: <20140626123709.GA9256@oc0268524204.ibm.com>
References: <1403354888-15600-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <CAB=NE6VWa4O0nycSo55ip075MEXXB_0k4wVnorSziRQmKRUmLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6VWa4O0nycSo55ip075MEXXB_0k4wVnorSziRQmKRUmLg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 04:08:21PM -0700, Luis R. Rodriguez wrote:
> On Sat, Jun 21, 2014 at 5:48 AM, Thadeu Lima de Souza Cascardo
> <cascardo@linux.vnet.ibm.com> wrote:
> > That use was removed by commit
> > 8c367fcbe6549195d2eb11e62bea233f811aad41 ("cxgb4: Do not set
> > net_device::dev_id to VI index"), since dev_id should be used only when
> > devices share the same MAC address.
> >
> > Using dev_port for cxgb4 allows different ports on the same PCI function
> > to be identified.
> 
> Can you describe what issues were introduced because of this then?
> 
>   Luis
> 

udevd builtin net-id cannot rename the interfaces, since it relies on
the dev_id for interfaces on the same PCI function. I am going to send a
patch to use dev_port instead, and fallback to dev_id, and copy netdev.

Regards.
Cascardo.
