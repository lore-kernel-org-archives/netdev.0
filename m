From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 4/4] bnx2i: Add bnx2i iSCSI driver.
Date: Wed, 20 May 2009 17:51:42 -0500
Message-ID: <4A14897E.9000006@cs.wisc.edu>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com> <1241208039-6813-5-git-send-email-mchan@broadcom.com> <4A01BF6A.90707@cs.wisc.edu> <1241715824.9177.8.camel@HP1> <4A034C2A.50107@cs.wisc.edu> <1242697859.10180.147.camel@HP1> <4A12C08A.1080600@cs.wisc.edu> <1242766039.10180.178.camel@HP1> <4A132B6B.5030008@cs.wisc.edu> <1242838735.10180.228.camel@HP1> <4A14608F.6070800@cs.wisc.edu> <1242858164.10180.316.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Karen Xie <kxie@chelsio.com>,
	Anil Veerabhadrappa <anilgv@broadcom.com>,
	Benjamin Li <benli@broadcom.com>
To: open-iscsi@googlegroups.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1242858164.10180.316.camel@HP1>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> 
> On Wed, 2009-05-20 at 12:57 -0700, Mike Christie wrote:
>> Michael Chan wrote:
>>> diff --git a/include/scsi/iscsi_if.h b/include/scsi/iscsi_if.h
>>> index 2c1a4af..0990dbb 100644
>>> --- a/include/scsi/iscsi_if.h
>>> +++ b/include/scsi/iscsi_if.h
>>> @@ -23,6 +23,9 @@
>>>  
>>> + */
>>> +struct iscsi_path {
>>> +	uint64_t	handle;
>>> +	uint8_t		mac_addr[6];
>>> +	uint8_t		mac_addr_old[6];
>>> +	uint32_t	ip_addr_len;	/* 4 or 16 */
>>> +	union {
>>> +		struct in_addr	v4_addr;
>>> +		struct in6_addr	v6_addr;
>>> +	} src;
>>> +	union {
>>> +		struct in_addr	v4_addr;
>>> +		struct in6_addr	v6_addr;
>> I think we have to include in6.h and in.h in this file, right? iser 
>> would not compile with this patch without it. If that is right and it 
>> works for you now, I can just fix it when I merge the patch.
>>
> 
> Yes, either include these files here in iscsi_if.h or include them in
> places where iscsi_if.h is included.  Which way do you prefer?
> 

Here is fine.
