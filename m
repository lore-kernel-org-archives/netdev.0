From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Thu, 23 May 2013 00:45:31 +0100
Message-ID: <1369266331.2670.40.camel@bwh-desktop.uk.level5networks.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org>
	 <1368498506-25857-7-git-send-email-yinghai@kernel.org>
	 <51925FB0.4080504@intel.com>
	 <CAE9FiQXYQEAZ=0sG6+2OdffBqfLS9MpoN1xviRR9aDbxPxcKxQ@mail.gmail.com>
	 <5192946F.1050700@intel.com>
	 <CAE9FiQVGGHB_amKw0-DfDifpTnRGPbxA+q3WY5F-O3x-sx386A@mail.gmail.com>
	 <5192AEF4.1070905@intel.com> <519BE778.9040800@redhat.com>
	 <20130521214912.GA21713@redhat.com> <519BEEA4.2030804@gmail.com>
	 <20130521221117.GB803@redhat.com> <519BF594.1020607@gmail.com>
	 <CAJZOPZKsp2_Fr3xY0NZfz5QDLn-=2fn+kL0w55EihuUgDZWEiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Don Dutile <ddutile@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Yinghai Lu <yinghai@kernel.org>,
	"Bjorn Helgaas" <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZKsp2_Fr3xY0NZfz5QDLn-=2fn+kL0w55EihuUgDZWEiw@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-22 at 23:16 +0300, Or Gerlitz wrote:
[...]
> all in all, we will look into returning  -EPROBE_DEFER from the VF
> when they identify the problematic situation -- so for how much time
> this is deferred? or if this isn't time based what the logical
> condition which once met the VF probe is attempted again?

My reading is that it will be retried as soon as the PF probe returns.
But I've never tried using this feature myself.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
