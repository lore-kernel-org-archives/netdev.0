From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Subject: Re: [Xen-devel] [RFC PATCH 34/35] Add the Xen virtual network device	driver.
Date: Wed, 10 May 2006 07:36:57 +0100
Message-ID: <c40c8b573caa8bf4931382d5e4722318@cl.cam.ac.uk>
References: <20060509085201.446830000@sous-sol.org> <E1FdatV-0000lj-00@gondolin.me.apana.org.au> <20060509235122.GJ24291@moss.sous-sol.org>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.osdl.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xensource.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	ian.pratt@xensource.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta2.cl.cam.ac.uk ([128.232.0.14]:35563 "EHLO mta2.cl.cam.ac.uk")
	by vger.kernel.org with ESMTP id S1750805AbWEJGlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 02:41:21 -0400
In-Reply-To: <20060509235122.GJ24291@moss.sous-sol.org>
To: Chris Wright <chrisw@sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10 May 2006, at 00:51, Chris Wright wrote:

> * Herbert Xu (herbert@gondor.apana.org.au) wrote:
>> Chris Wright <chrisw@sous-sol.org> wrote:
>>>
>>> +       netdev->features        = NETIF_F_IP_CSUM;
>>
>> Any reason why IP_CSUM was chosen instead of HW_CSUM? Doing the latter
>> would seem to be in fact easier for a virtual driver, no?
>
> That, I really don't know.

Checksum offload was added late to the virtual transport and currently 
not enough info is carried to identify protocol checksum fields in 
arbitrary locations. When we rev the virtual interface, and include a 
proper checksum-offset field, we'll be able to switch to 
NETIF_F_HW_CSUM.

  -- Keir

