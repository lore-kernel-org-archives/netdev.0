From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v11 03/17] Add a ndo_mp_port_prep pointer to
 net_device_ops.
Date: Wed, 29 Sep 2010 21:41:54 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D792EC64F8157@shsmsx502.ccr.corp.intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
	 <79267b300503d98d43ccfcf11d1374f59fec8578.1285385607.git.xiaohui.xin@intel.com>
 <1285594953.2263.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1285594953.2263.5.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, I will comment it above the structure.

Thanks
Xiaohui

>-----Original Message-----
>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Monday, September 27, 2010 9:43 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>jdike@linux.intel.com
>Subject: Re: [PATCH v11 03/17] Add a ndo_mp_port_prep pointer to net_device_ops.
>
>On Sat, 2010-09-25 at 12:27 +0800, xiaohui.xin@intel.com wrote:
>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>>
>> If the driver want to allocate external buffers,
>> then it can export it's capability, as the skb
>> buffer header length, the page length can be DMA, etc.
>> The external buffers owner may utilize this.
>[...]
>
>This information needs to be included in the comment above struct
>net_device_ops, not just in the commit message.
>
>Ben.
>
>--
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.

