From: Chaitanya Lala <clala@riverbed.com>
Subject: Re: [PATCH 1/1] ethtool: Expose MDI-X status
Date: Tue, 26 May 2009 08:34:52 -0700
Message-ID: <4A1C0C1C.8040401@riverbed.com>
References: <1243004704.3192.21.camel@achroite>	 <20090522171850.GA16751@clala-laptop> <1243040677.16597.52.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([206.169.144.12]:18807 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbZEZPeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 11:34:10 -0400
In-Reply-To: <1243040677.16597.52.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Fri, 2009-05-22 at 10:18 -0700, Chaitanya Lala wrote:
>   
>> The MDI-X status is a useful tool for diagnosing network
>> connectivity issues. We expose MDI-X status as a tri-state value
>> status which drivers can optionally implement.
>>
>> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
>> Signed-off-by: Arthur Jones <ajones@riverbed.com>
>> ---
>>  ethtool-copy.h |    6 ++++++
>>  ethtool.c      |   13 +++++++++++++
>>  2 files changed, 19 insertions(+), 0 deletions(-)
>>
>> diff --git a/ethtool-copy.h b/ethtool-copy.h
>> index 3ca4e2c..d3e1524 100644
>> --- a/ethtool-copy.h
>> +++ b/ethtool-copy.h
>> @@ -28,6 +28,7 @@ struct ethtool_cmd {
>>  	__u16	speed_hi;
>>  	__u16	reserved2;
>>  	__u32	reserved[3];
>> +	__u8	is_mdix;	/* Tri-state value to expose MDI-X */
>>  };
>>     
> [...]
>
> No, you cannot change the size of this structure either.
>   
Hi,

In that case please suggest a way to do this.

Thanks,
Chaitanya
> Ben.
>
>   

