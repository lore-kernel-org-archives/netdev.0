From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v3 2/8] thunderbolt: Updating device IDs
Date: Mon, 18 Jul 2016 09:54:10 +0000
Message-ID: <E607265CB020454880711A6F96C05A03893D025E@hasmsx107.ger.corp.intel.com>
References: <1468495702-7467-3-git-send-email-amir.jer.levy@intel.com>
	<20160715.114902.1149848183971707484.davem@davemloft.net>
	<E607265CB020454880711A6F96C05A03893CE285@hasmsx107.ger.corp.intel.com>
 <20160715.145345.1714630247405044715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>
To: 'David Miller' <davem@davemloft.net>,
	'Lukas Wunner' <lukas@wunner.de>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160715.145345.1714630247405044715.davem@davemloft.net>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 16 2016, 12:53 AM, David Miller wrote:
> From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
> Date: Fri, 15 Jul 2016 18:56:39 +0000
> 
> > On Fri, Jul 15 2016, 09:49 PM, David Miller wrote:
> >> From: Amir Levy <amir.jer.levy@intel.com>
> >> Date: Thu, 14 Jul 2016 14:28:16 +0300
> >>
> >> > Adding the new Thunderbolt(TM) device IDs to the list.
> >> >
> >> > Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> >>
> >> Unless these PCI-IDs, all of them, are going to be used in multiple
> >> spots in the kernel, it is not appropriate to add them here.
> >>
> >> They belong as private macros in the drivers themselves, instead.
> >
> > They might be used:
> > http://www.spinics.net/lists/linux-pci/msg51331.html
> 
> Then move them to the common location when this "might" thing actually
> happens.

There are several contradicting  comments about this change (http://www.spinics.net/lists/linux-pci/msg51331.html and http://www.spinics.net/lists/linux-pci/msg51302.html)
I've decided for now to make the new device ids private to the driver. 
This can be changed later when updating quirks for Apple hardware.

Regards,
Amir
