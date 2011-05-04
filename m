From: TB <lkml@techboom.com>
Subject: Re: Divide error in bictcp_cong_avoid ?
Date: Wed, 04 May 2011 15:03:13 -0400
Message-ID: <4DC1A2F1.80507@techboom.com>
References: <4DC178D3.6030308@techboom.com>	<20110504104940.cd0d9e9a.rdunlap@xenotime.net>	<20110504113351.4643a0c9@nehalam> <20110504113521.3c506a54.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110504113521.3c506a54.rdunlap@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-05-04 02:35 PM, Randy Dunlap wrote:
> On Wed, 4 May 2011 11:33:51 -0700 Stephen Hemminger wrote:
>
>> On Wed, 4 May 2011 10:49:40 -0700
>> Randy Dunlap<rdunlap@xenotime.net>  wrote:
>>
>>> [add cc to netdev]
>>>
>>>
>>> On Wed, 04 May 2011 12:03:31 -0400 TB wrote:
>>>
>>>> We're having this issue sporadically on a few servers and this is the
>>>> backtrace we get from netconsole.
>>>>
>>>>
>>>> [28522.642419] divide error: 0000 [#1] SMP
>>>> [28522.642457] last sysfs file:
>>>> /sys/devices/pci0000:00/0000:00:1f.2/host2/target2:0:0/2:0:0:0/vendor
>>>> [28522.642504] CPU 0
>>>> [28522.642511] Modules linked in:
>>>>    i2c_i801
>>>>    i2c_core
>>>>    evdev
>>>>    button
>>>> [28522.642570]
>>>> [28522.642590] Pid: 0, comm: swapper Not tainted 2.6.38.5 #6<<<<<<<<<<<<<<
>>>>
>>>>    Supermicro X8DTH-i/6/iF/6F
>>>> /
>>>>    X8DTH
>>>>
>>
>> What kernel version? I suspect they are running something really old
>> kernel like RHEL 5 since BIC has not been the default congestion control for
>> several years.
>
> Please see about 6 lines above.... at the "<<<<<<<<<<<".

/proc/sys/net/ipv4/tcp_available_congestion_control
cubic reno

cat /proc/sys/net/ipv4/tcp_congestion_control
cubic
