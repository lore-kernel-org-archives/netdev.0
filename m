From: "Li, Sibai" <sibai.li@intel.com>
Subject: Re: SR-IOV problem with Intel 82599EB (not enough
 MMIO resources for SR-IOV)
Date: Tue, 13 Nov 2012 18:25:58 +0000
Message-ID: <A3A921390EAE4044940E99EBF13D97321AE21FBB@FMSMSX104.amr.corp.intel.com>
References: <201211081915083774239@gmail.com>	<509B962C.6070002@gmail.com>
	<C5551D9AAB213A418B7FD5E4A6F30A072D565E76@ORSMSX106.amr.corp.intel.com>
	<CANmqhJDJXcbUxyt6YD6ktxZCDJ=VqiwhGXP+fLMukQr0o-XwxQ@mail.gmail.com>
	<CAErSpo4xn9t=4yXGLdPQMtUJF=n38tYrMutAoj7NCsLUzQEbcg@mail.gmail.com>
	<CANmqhJAjwP8CLEKpgsDbT-7+n=hf30LbYrTAu+qDH09LzETD4g@mail.gmail.com>
	<A3A921390EAE4044940E99EBF13D97321AE21E15@FMSMSX104.amr.corp.intel.com>
	<CAE9FiQXnP2gpy9z6VNGSpimLkhDYKp6Qr=9nGZ9d-pKdohA4bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"ddutile@redhat.com" <ddutile@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAE9FiQXnP2gpy9z6VNGSpimLkhDYKp6Qr=9nGZ9d-pKdohA4bw@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: yhlu.kernel@gmail.com [mailto:yhlu.kernel@gmail.com] On Behalf Of
> Yinghai Lu
> Sent: Tuesday, November 13, 2012 10:17 AM
> To: Li, Sibai
> Cc: Jason Gao; bhelgaas@google.com; Rose, Gregory V; ddutile@redhat.com;
> Kirsher, Jeffrey T; linux-kernel; netdev; kvm; e1000-devel@lists.sourceforge.net;
> linux-pci@vger.kernel.org
> Subject: Re: SR-IOV problem with Intel 82599EB (not enough MMIO resources
> for SR-IOV)
> 
> On Tue, Nov 13, 2012 at 8:04 AM, Li, Sibai <sibai.li@intel.com> wrote:
> >
> >>
> >> Thank you very much,I try "pci=realloc" in Centos 6.3,and now it works for
> me.
> >>
> >> thank you Sibai,Our server "Dell R710",its BIOS version is just
> >> v.6.3.0 and release date is 07/24/2012,and I also configured
> >> intel_iommu=on in the grub.conf file,but I can't find these IOMMU
> >> options in "Device Drivers" in my
> >> kernel(2.6.32-279) .config file , btw my os is Centos
> >> 6.3(RHEL6.3),although the problem solved,I'd like to know what's your os
> version ,kernel version?
> >
> > I am using RHEL6.3 with unstable kernel 3.7.0-rc
> 
> that means that config has
> CONFIG_PCI_REALLOC_ENABLE_AUTO=y
> 
> So you don't need to append "pci=realloc"
> 
> Yinghai

Never append "pci=realloc" for both kernel 2.6.32.279 and kernel 3.5.0 above.

------------------------------------------------------------------------------
Monitor your physical, virtual and cloud infrastructure from a single
web console. Get in-depth insight into apps, servers, databases, vmware,
SAP, cloud infrastructure, etc. Download 30-day Free Trial.
Pricing starts from $795 for 25 servers or applications!
http://p.sf.net/sfu/zoho_dev2dev_nov
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
