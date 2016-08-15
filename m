From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Tue, 16 Aug 2016 08:23:19 +1000
Message-ID: <1471299799.12231.121.camel@kernel.crashing.org>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
	 <1452684335-46107-4-git-send-email-hare@suse.de>
	 <20160209210458.GB32530@localhost>
	 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
	 <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
	 <1470787409.3015.81.camel@kernel.crashing.org>
	 <CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
	 <1470873296.3015.117.camel@kernel.crashing.org>
	 <CAKgT0UcPh2RZazDL-cJbJkZFUJ03kTocn5H7WA=Kk_+S-CV_HA@mail.gmail.com>
	 <20160811141700.4f4faabb@t450s.home>
	 <1470978669.3015.155.camel@kernel.crashing.org>
	 <197F6532-FC5E-4D72-976D-4207BAD8D83E@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alex Williamson <alex.williamson@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	"santosh@chelsio.com" <santosh@chelsio.com>,
	Netdev <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <197F6532-FC5E-4D72-976D-4207BAD8D83E@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-08-15 at 17:59 +0000, Rustad, Mark D wrote:
> > Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > 
> > We may want some kind of "strict" vs. "relaxed" model here to
> > differenciate the desktop user wanting to give a function to his/her
> > windows partition and doesn't care about strict isolation vs. the cloud
> > data center.
> 
> I don't think desktop users appreciate hangs any more than anyone else, and  
> that is one of the symptoms that can arise here without the vfio  
> coordination.

And can happen with it as well.... 

Put it this way, we have a hole the size of a football field and we are
spending all that time "plugging" it by putting a 3 foot gate in the
middle of it... ugh.

VFIO shouldn't try to get between the device driver and the HW, it doesn't
work. It cannot work.

Cheers,
Ben.
