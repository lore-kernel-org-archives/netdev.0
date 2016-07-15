From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v3 2/8] thunderbolt: Updating device IDs
Date: Fri, 15 Jul 2016 18:56:39 +0000
Message-ID: <E607265CB020454880711A6F96C05A03893CE285@hasmsx107.ger.corp.intel.com>
References: <1468495702-7467-1-git-send-email-amir.jer.levy@intel.com>
	<1468495702-7467-3-git-send-email-amir.jer.levy@intel.com>
 <20160715.114902.1149848183971707484.davem@davemloft.net>
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
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59701 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292AbcGOS4p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:56:45 -0400
In-Reply-To: <20160715.114902.1149848183971707484.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15 2016, 09:49 PM, David Miller wrote:
> From: Amir Levy <amir.jer.levy@intel.com>
> Date: Thu, 14 Jul 2016 14:28:16 +0300
> 
> > Adding the new Thunderbolt(TM) device IDs to the list.
> >
> > Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> 
> Unless these PCI-IDs, all of them, are going to be used in multiple spots in the
> kernel, it is not appropriate to add them here.
> 
> They belong as private macros in the drivers themselves, instead.

They might be used: http://www.spinics.net/lists/linux-pci/msg51331.html
