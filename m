From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Thu, 15 Nov 2012 19:14:23 +0800
Message-ID: <50A4CE8F.80400@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <1352969589.3499.31.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45257 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423250Ab2KOLO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 06:14:27 -0500
In-Reply-To: <1352969589.3499.31.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 16:53, Ian Campbell wrote:
> On Thu, 2012-11-15 at 07:03 +0000, Annie Li wrote:
>> This patch is based on linux3.4-rc3. I hit netperf/netserver failure
>> on linux latest version v3.7-rc1, v3.7-rc2 and v3.7-rc4. Not sure
>> whether thisnetperf/netserver failure connects compound page commit in
>> v3.7-rc1, but I did hit BUG_ON with debug patch from thread
>> http://lists.xen.org/archives/html/xen-devel/2012-10/msg00893.html
> Do you think you could cook up a netfront fix similar in principal to
> the 6a8ed462f16b8455eec5ae00eb6014159a6721f0 fix for netback?

Ok, let me have a try to do similar thing in netfront.

Thanks
Annie
>
> Ian.
>
>
