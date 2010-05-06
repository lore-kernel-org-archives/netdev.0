From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Thu, 6 May 2010 00:25:20 -0700
Message-ID: <89E2752CFA8EC044846EB8499819134102AF2D23E5@EXCH-MBX-4.vmware.com>
References: <89E2752CFA8EC044846EB8499819134102AF2896F5@EXCH-MBX-4.vmware.com>
 <C807719A.2E910%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Christoph Hellwig <hch@infradead.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	Pankaj Thakkar <pthakkar@vmware.com>
To: Scott Feldman <scofeldm@cisco.com>, Arnd Bergmann <arnd@arndb.de>,
	Dmitry Torokhov <dtor@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C807719A.2E910%scofeldm@cisco.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Scott Feldman [mailto:scofeldm@cisco.com]
> Sent: Wednesday, May 05, 2010 7:04 PM
> To: Shreyas Bhatewara; Arnd Bergmann; Dmitry Torokhov
> Cc: Christoph Hellwig; pv-drivers@vmware.com; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org; virtualization@lists.linux-
> foundation.org; Pankaj Thakkar
> Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for
> vmxnet3
> 
> On 5/5/10 10:29 AM, "Dmitry Torokhov" <dtor@vmware.com> wrote:
> 
> > It would not be a binary blob but software properly released under
> GPL.
> > The current plan is for the shell to enforce GPL requirement on the
> > plugin code, similar to what module loaded does for regular kernel
> > modules.
> 
> On 5/5/10 3:05 PM, "Shreyas Bhatewara" <sbhatewara@vmware.com> wrote:
> 
> > The plugin image is not linked against Linux kernel. It is OS
> agnostic infact
> > (Eg. same plugin works for Linux and Windows VMs)
> 
> Are there any issues with injecting the GPL-licensed plug-in into the
> Windows vmxnet3 NDIS driver?
> 
> -scott

Scott,
Thanks for pointing out. This issue can be resolved by adding exception to the plugin license which allows it to link to a non-free program .(http://www.gnu.org/licenses/gpl-faq.html#GPLPluginsInNF)

->Shreyas
