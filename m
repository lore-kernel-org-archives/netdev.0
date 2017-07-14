From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v7 3/3] net/cxgb4: Use new
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Fri, 14 Jul 2017 18:23:51 +0800
Message-ID: <d36574a1-2853-6989-25ae-5fd1b0d811ba@huawei.com>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
 <1499955692-26556-4-git-send-email-dingtianhong@huawei.com>
 <CAKgT0UcBFBk9T7g0Dh-rHY6Z+6-4=5jsUWHbLcSMc+ohdTz=CA@mail.gmail.com>
 <CAKgT0Uf8Tg6AFthXt-bJrdNHCqJ3MfzduR1yCMMsjLYoEFXb-w@mail.gmail.com>
 <MWHPR12MB1600E5A4404EE9D97CD99F88C8AC0@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Gabriele Paoloni <gabriele.paoloni@huawei.com>,
 Asit K Mallick <asit.k.mallick@intel.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 LinuxArm <linuxarm@huawei.com>, Ashok Raj <ashok.raj@intel.com>,
 Bjorn Helgaas <helgaas@kernel.org>, Jeff
 Kirsher <jeffrey.t.kirsher@intel.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 Ganesh GR <ganeshgr@chelsio.com>, Bob Shaw <Bob.Shaw@amd.com>,
 Patrick J Cramer <patrick.j.cramer@intel.com>,
 Bjorn Helgaas <bhelgaas@google.com>, Michael Werner <werner@chelsio.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Amir Ancel <amira@mellanox.com>, Netdev <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 David Laight <David.Laight@aculab.com>,
 Suravee Suthikulpanit <Suravee.Suthikulpa
To: Casey Leedom <leedom@chelsio.com>, Alexander Duyck
 <alexander.duyck@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <MWHPR12MB1600E5A4404EE9D97CD99F88C8AC0@MWHPR12MB1600.namprd12.prod.outlook.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Casey, Alexander:

Thanks for the great efforts from both of you, It looks like we have reached a consensus finally,
could you please add a confirmation message just like Reviewed-by or something else, thanks. :)

Ding

On 2017/7/14 2:44, Casey Leedom wrote:
>   Yeah, I think this works for now.  We'll stumble over what to do when we want to mix upstream TLPs without Relaxed Ordering Attributes directed at problematic Root Complexes, and Peer-to-Peer TLPs with Relaxed Ordering Attributes ... or vice versa depending on which target PCIe Device has issues with Relaxed Ordering.
> 
> 
>   Thanks for all the work!
> 
> 
> Casey
> 
> 
