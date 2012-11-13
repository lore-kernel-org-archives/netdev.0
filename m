From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: SR-IOV problem with Intel 82599EB (not enough MMIO resources for SR-IOV)
Date: Tue, 13 Nov 2012 10:16:57 -0800
Message-ID: <CAE9FiQXnP2gpy9z6VNGSpimLkhDYKp6Qr=9nGZ9d-pKdohA4bw@mail.gmail.com>
References: <201211081915083774239@gmail.com>
	<509B962C.6070002@gmail.com>
	<C5551D9AAB213A418B7FD5E4A6F30A072D565E76@ORSMSX106.amr.corp.intel.com>
	<CANmqhJDJXcbUxyt6YD6ktxZCDJ=VqiwhGXP+fLMukQr0o-XwxQ@mail.gmail.com>
	<CAErSpo4xn9t=4yXGLdPQMtUJF=n38tYrMutAoj7NCsLUzQEbcg@mail.gmail.com>
	<CANmqhJAjwP8CLEKpgsDbT-7+n=hf30LbYrTAu+qDH09LzETD4g@mail.gmail.com>
	<A3A921390EAE4044940E99EBF13D97321AE21E15@FMSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jason Gao <pkill.2012@gmail.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"ddutile@redhat.com" <ddutile@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Li, Sibai" <sibai.li@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <A3A921390EAE4044940E99EBF13D97321AE21E15@FMSMSX104.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2012 at 8:04 AM, Li, Sibai <sibai.li@intel.com> wrote:
>
>>
>> Thank you very much,I try "pci=realloc" in Centos 6.3,and now it works for me.
>>
>> thank you Sibai,Our server "Dell R710",its BIOS version is just
>> v.6.3.0 and release date is 07/24/2012,and I also configured intel_iommu=on in
>> the grub.conf file,but I can't find these IOMMU options in "Device Drivers" in my
>> kernel(2.6.32-279) .config file , btw my os is Centos 6.3(RHEL6.3),although the
>> problem solved,I'd like to know what's your os version ,kernel version?
>
> I am using RHEL6.3 with unstable kernel 3.7.0-rc

that means that config has
CONFIG_PCI_REALLOC_ENABLE_AUTO=y

So you don't need to append "pci=realloc"

Yinghai
