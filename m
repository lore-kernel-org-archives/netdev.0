From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] xen/xenbus: Use 'void' instead of 'int' for the return
 of xenbus_switch_state()
Date: Tue, 30 Sep 2014 18:10:51 +0800
Message-ID: <542A81AB.3050702@gmail.com>
References: <5425961A.5000604@gmail.com> <542A7E0E.9050702@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>, konrad.wilk@oracle.com,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	boris.ostrovsky@oracle.com, bhelgaas@google.com, jgross@suse.com,
	yongjun_wei@trendmicro.com.cn, mukesh.rathor@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <542A7E0E.9050702@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/30/14 17:55, David Vrabel wrote:
> On 26/09/14 17:36, Chen Gang wrote:
>> When xenbus_switch_state() fails, it will call xenbus_switch_fatal()
>> internally, so need not return any status value, then use 'void' instead
>> of 'int' for xenbus_switch_state() and __xenbus_switch_state().
>>
>> Also need be sure that all callers which check the return value must let
>> 'err' be 0.
>>
>> And also need change the related comments for xenbus_switch_state().
> 
> Since this patch does not fix a bug and there is no unanimous agreement
> on the API change I'm not going to apply it (nor the previous version).
> 

OK, at least for me, it is no problems.

But I still recommend to improve it in the future, it is not a good idea
to let all related things remain in current condition (for me, at lease
need some related code comments for it).


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
