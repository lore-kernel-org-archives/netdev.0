From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v16 14/17]Add a kconfig entry and make entry for mp
 device.
Date: Thu, 2 Dec 2010 09:32:31 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D793622D741CB@shsmsx502.ccr.corp.intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1291187695.git.xiaohui.xin@intel.com>
	<a1c255bc496b7aaca26912790f8bb0162dd1f4bf.1291187695.git.xiaohui.xin@intel.com>
 <20101201095348.07421ee5.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30509 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664Ab0LBBeW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 20:34:22 -0500
In-Reply-To: <20101201095348.07421ee5.randy.dunlap@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Randy Dunlap [mailto:randy.dunlap@oracle.com]
>Sent: Thursday, December 02, 2010 1:54 AM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mst@redhat.com; mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>jdike@linux.intel.com
>Subject: Re: [PATCH v16 14/17]Add a kconfig entry and make entry for mp device.
>
>On Wed,  1 Dec 2010 16:08:25 +0800 xiaohui.xin@intel.com wrote:
>
>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>>
>> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
>> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
>> ---
>>  drivers/vhost/Kconfig  |   10 ++++++++++
>>  drivers/vhost/Makefile |    2 ++
>>  2 files changed, 12 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
>> index e4e2fd1..a6b8cbf 100644
>> --- a/drivers/vhost/Kconfig
>> +++ b/drivers/vhost/Kconfig
>> @@ -9,3 +9,13 @@ config VHOST_NET
>>  	  To compile this driver as a module, choose M here: the module will
>>  	  be called vhost_net.
>>
>> +config MEDIATE_PASSTHRU
>> +	tristate "mediate passthru network driver (EXPERIMENTAL)"
>> +	depends on VHOST_NET
>> +	---help---
>> +	  zerocopy network I/O support, we call it as mediate passthru to
>
>	                       support; we call it "mediate passthru" to
>
>> +	  be distiguish with hardare passthru.
>
>	  distinguish it from hardware passthru.
>

Thanks. I will modify that.

Thanks
Xiaohui

>> +
>> +	  To compile this driver as a module, choose M here: the module will
>> +	  be called mpassthru.
>> +
>
>
>---
>~Randy
>*** Remember to use Documentation/SubmitChecklist when testing your code ***
