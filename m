From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000e 0000:00:19.0: DMA-API: device driver tries to free DMA
	memory it has not allocated [device address=0x0000000052ff084a]	[size=90
 bytes]
Date: Wed, 18 Mar 2009 09:43:02 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1E8795AC@orsmsx507.amr.corp.intel.com>
References: <1237223130-26519-1-git-send-email-joerg.roedel@amd.com>
 <20090317120112.GP6159@amd.com> <20090318093847.GC5879@elte.hu>
 <20090318115615.GS6159@amd.com> <20090318120458.GA1601@elte.hu>
 <36697.89.102.207.186.1237380871.squirrel@mail.v3.sk>
 <20090318140949.GA20852@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Joerg Roedel <joerg.roedel@amd.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Ingo Molnar <mingo@redhat.com>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>, Lubomir Rintel <lkundrak@v3.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35072 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301AbZCRQnF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 12:43:05 -0400
In-Reply-To: <20090318140949.GA20852@elte.hu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Lubomir Rintel <lkundrak@v3.sk> wrote:
> 
>> On Wed, March 18, 2009 8:04 am, Ingo Molnar wrote:
>>> 
>>> ( e1000e Cc:s added. A new debug feature, CONFIG_DMA_API_DEBUG=y,
>>>   has triggered the warning below in e1000_put_txbuf(). )
>> 
>> http://lkml.org/lkml/2009/3/2/318

We are still looking for more testing from the general community of 
this patch, in particular if any tx hangs are reported.  Thanks in 
advance for any reports.