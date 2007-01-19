From: Steve Wise <swise@opengridcomputing.com>
Subject: [Fwd: Re: [PATCH 1/10] cxgb3 - main header files]
Date: Fri, 19 Jan 2007 08:28:16 -0600
Message-ID: <1169216896.15842.6.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: openib-general <openib-general@openib.org>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:54161 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965040AbXASO2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 09:28:16 -0500
To: Roland Dreier <rdreier@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Roland, 

Jeff has pulled in the Chelsio Ethernet driver.  If you are ready to
merge in the RDMA driver, you can pull it from 

git://staging.openfabrics.org/~swise/cxgb3.git for-roland

Thanks,

Steve.


-------- Forwarded Message --------
From: Jeff Garzik <jeff@garzik.org>
To: Divy Le Ray <divy@chelsio.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
swise@opengridcomputing.com
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Thu, 18 Jan 2007 22:05:02 -0500

Divy Le Ray wrote:
> Jeff Garzik wrote:
>> Divy Le Ray wrote:
>>> From: Divy Le Ray <divy@chelsio.com>
>>>
>>> This patch implements the main header files of
>>> the Chelsio T3 network driver.
>>>
>>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>>
>> Once you think it's ready, email me a URL to a single patch that adds 
>> the driver to the latest linux-2.6.git kernel.  Include in the email a 
>> description of the driver and signed-off-by line, which will get 
>> directly included in the git changelog.
>>
>> Adding new drivers is a bit special, because we want to merge it as a 
>> single changeset, but that would create a patch too large to review on 
>> the common kernel mailing lists.
> Jeff,
> 
> You can grab the monolithic patch at this URL:
> http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

applied to netdev-2.6.git#upstream

I'm really counting on Chelsio to actively maintain this driver, unlike 
the abandonware you guys first submitted.

	Jeff




