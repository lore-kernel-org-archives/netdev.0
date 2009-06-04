From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH net-next 2/2] cxgb3: Add Aeluros 2020 phy support
Date: Wed, 03 Jun 2009 19:27:41 -0700
Message-ID: <4A27311D.7070400@chelsio.com>
References: <20090529075823.30669.28885.stgit@speedy5> <20090529075829.30669.41488.stgit@speedy5> <20090601105349.GF3051@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756600AbZFDCcU@vger.kernel.org>
In-Reply-To: <20090601105349.GF3051@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings wrote:
> On Fri, 2009-05-29 at 00:58 -0700, Divy Le Ray wrote:
> [...]
>   
>> +	/* TWINAX EDC firmware */
>> +	static u16 twinax_edc[] = {
>> +		0xd800, 0x4009,
>> +		0xd801, 0x2fff,
>> +		0xd802, 0x300f,
>> +		0xd803, 0x40aa,
>> +		0xd804, 0x401c,
>>     
> [...]
>
> Use request_firmware() please.
>
> Ben.
>
>   

Hi Ben,

Sorry for the late reply.

The registers controlling the electronic dispersion compensation
need to be programmed based on the module inserted when the phy gets out 
of reset.

In a boot over the network environment, request_firmware() will not be 
granted
access to the file system. The EDC registers setup would be problematic.

Cheers,
Divy
 
