From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] tc-tbf.8: Add parameter range to man page.
Date: Mon, 20 Aug 2012 14:36:12 +0800
Message-ID: <5031DADC.6060509@cn.fujitsu.com>
References: <1344306632-15288-1-git-send-email-lw@cn.fujitsu.com> <20120813083015.27b66cd7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15192 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab2HTGhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 02:37:10 -0400
In-Reply-To: <20120813083015.27b66cd7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2012 11:30 PM, Stephen Hemminger wrote:
> On Tue, 7 Aug 2012 10:30:32 +0800
> Li Wei <lw@cn.fujitsu.com> wrote:
> 
>> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
>> ---
>>  man/man8/tc-tbf.8 |    6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/man/man8/tc-tbf.8 b/man/man8/tc-tbf.8
>> index 3abb238..7b76146 100644
>> --- a/man/man8/tc-tbf.8
>> +++ b/man/man8/tc-tbf.8
>> @@ -76,6 +76,7 @@ latency parameter, which specifies the maximum amount of time a packet can
>>  sit in the TBF. The latter calculation takes into account the size of the
>>  bucket, the rate and possibly the peakrate (if set). These two parameters
>>  are mutually exclusive. 
>> +The range of parameter limit is [1, UINT32_MAX] bytes.
>>  .TP
>>  burst
>>  Also known as buffer or maxburst.
>> @@ -85,6 +86,7 @@ if you want to reach your configured rate!
>>  
>>  If your buffer is too small, packets may be dropped because more tokens arrive per timer tick than fit in your bucket.
>>  The minimum buffer size can be calculated by dividing the rate by HZ.
>> +The range of this parameter is [1, UINT32_MAX] bytes.
>>  
>>  Token usage calculations are performed using a table which by default has a resolution of 8 packets. 
>>  This resolution can be changed by specifying the 
>> @@ -96,11 +98,13 @@ this. Must be an integral power of 2.
>>  mpu
>>  A zero-sized packet does not use zero bandwidth. For ethernet, no packet uses less than 64 bytes. The Minimum Packet Unit 
>>  determines the minimal token usage (specified in bytes) for a packet. Defaults to zero.
>> +The range of this parameter is [0, UINT32_MAX] bytes.
>>  .TP
>>  rate
>>  The speed knob. See remarks above about limits! See 
>>  .BR tc (8)
>>  for units.
>> +The range of this parameter is [1, UINT32_MAX] bps.
>>  .PP
>>  Furthermore, if a peakrate is desired, the following parameters are available:
>>  
>> @@ -108,12 +112,14 @@ Furthermore, if a peakrate is desired, the following parameters are available:
>>  peakrate
>>  Maximum depletion rate of the bucket. Limited to 1mbit/s on Intel, 10mbit/s on Alpha. The peakrate does 
>>  not need to be set, it is only necessary if perfect millisecond timescale shaping is required.
>> +The range of this parameter is [1, UINT32_MAX] bps.
>>  
>>  .TP
>>  mtu/minburst
>>  Specifies the size of the peakrate bucket. For perfect accuracy, should be set to the MTU of the interface.
>>  If a peakrate is needed, but some burstiness is acceptable, this size can be raised. A 3000 byte minburst
>>  allows around 3mbit/s of peakrate, given 1000 byte packets.
>> +The range of this parameter is [1, UINT32_MAX] bytes.
>>  
>>  Like the regular burstsize you can also specify a 
>>  .B cell
> 
> Not sure about this, other qdisc don't document ranges on their man pages.
> Probably better to fix the generic documentation about qdisc parameters
> which already exists on 'tc-qdisc' man page.

Hi Stephen,

Not very clear with "the generic documentation about qdisc parameters
which already exists on 'tc-qdisc' man page", is there a separate man page
that describe qdisc parameters?

I'm reading the iproute2 and kernel code which related to TC and record the
value range for each parameter, I think that would be helpful for somebody
else.

Thanks.

> 
