From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Tue, 9 Sep 2008 11:30:29 +0200
Message-ID: <f4845fc0809090230h1cbc01ev45c6ab4bdba61955@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
	 <20080908234028.GF13048@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	"=?ISO-8859-1?Q?Siim_P=F5der?=" <siim@p6drad-teel.net>,
	"Julian Anastasov" <ja@ssi.bg>,
	"Malcolm Turnbull" <malcolm@loadbalancer.org>,
	"Vince Busam" <vbusam@google.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:53603 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402AbYIIJah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 05:30:37 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id m899UU5D027331
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2008 10:30:30 +0100
Received: from wx-out-0506.google.com (wxdh30.prod.google.com [10.70.134.30])
	by wpaz37.hot.corp.google.com with ESMTP id m899UTPh015264
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2008 02:30:29 -0700
Received: by wx-out-0506.google.com with SMTP id h30so556825wxd.18
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2008 02:30:29 -0700 (PDT)
In-Reply-To: <20080908234028.GF13048@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2008 at 1:40 AM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 08, 2008 at 12:04:20PM +1000, Simon Horman wrote:
>> Hi,
>>
>> The impetus for this series of patches is Julian Anastasov noting
>> that "load balance IPv4 connections from a local process" checks
>> for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
>> even on loopback traffic, but that rather partial checksums are
>> possible.
>>
>> The first patch in this series is a proposed solution to handle
>> partial checksums for both TCP and UDP.
>>
>> The other two patches clean things up a bit.
>>
>> I have not tested this code beyond compilation yet.
>
> After extensive testing by Julius Volz and limited testing by myself, I
> have applied the first patch, which does indeed allow packets with
> PARTIAL_CHECKSUM to work, to lvs-next-2.6. I have dropped the second two
> patches which produce bogus checksums.

Great, thanks! I have tested TCP+UDP, local+remote clients, v4+v6,
NAT+DSR+TUN in all combinations that are expected to be working and
found no problems.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
