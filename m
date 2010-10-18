From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v12 12/17] Add mp(mediate passthru) device.
Date: Mon, 18 Oct 2010 16:30:52 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D79306C1B33FE@shsmsx502.ccr.corp.intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
 <c898c79a9a73f531d790d9983bf01b9aa05752b1.1285853725.git.xiaohui.xin@intel.com>
 <20101003131254.GB19184@redhat.com>
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
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57500 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892Ab0JRIcI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 04:32:08 -0400
In-Reply-To: <20101003131254.GB19184@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Michael S. Tsirkin [mailto:mst@redhat.com]
>Sent: Sunday, October 03, 2010 9:13 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>jdike@linux.intel.com
>Subject: Re: [PATCH v12 12/17] Add mp(mediate passthru) device.
>
>On Thu, Sep 30, 2010 at 10:04:30PM +0800, xiaohui.xin@intel.com wrote:
>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>>
>> The patch add mp(mediate passthru) device, which now
>> based on vhost-net backend driver and provides proto_ops
>> to send/receive guest buffers data from/to guest vitio-net
>> driver.
>>
>> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
>> Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
>> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
>
>So you plan to rewrite all this to make this code part of macvtap?
>
V13 exports functions which can be reused by macvtap to get zero-copy.
Currently, I'm adding code in macvtap and trying to make it work.

Thanks
Xiaohui
