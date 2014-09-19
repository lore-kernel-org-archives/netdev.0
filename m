From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 00/29] Add support for the Intel FM10000 Ethernet
 Switch Host Interface
Date: Fri, 19 Sep 2014 11:22:45 -0700
Message-ID: <541C7475.8050800@intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>	<541C0C01.6080708@mojatatu.com>	<541C43AE.3030402@intel.com> <CAADnVQKuzQ82HgMXaKcjxZXwGXB6FchhC536u=KfnBLP3+U-Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, nhorman@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	matthew.vick@intel.com, jeffrey.t.kirsher@intel.com,
	sassmann@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:62715 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932269AbaISSZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 14:25:17 -0400
In-Reply-To: <CAADnVQKuzQ82HgMXaKcjxZXwGXB6FchhC536u=KfnBLP3+U-Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 09:58 AM, Alexei Starovoitov wrote:
> On Fri, Sep 19, 2014 at 7:54 AM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>>
>> Since the switch can support up to 9 of these we are treating the host
>> interface driver as though it is a NIC driver.  We need to usually ship
> 
> Am I reading it right that 9 hosts can be attached to this one physical device
> and they see it as different 'physical' nics ?
> 

No, there are up to 9 independent host interfaces that are attached to
the switch.  Each host device shows up as a separate PCI device capable
of SR-IOV.  If SR-IOV is enabled with 64 VFs then one Host interface
will appear as 1 PF PCI device, and 64 VF PCI devices.

Thanks,

Alex
