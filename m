From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/9] sh_eth: make driver build on any platform
Date: Sat, 08 Jun 2013 17:24:27 +0400
Message-ID: <51B3308B.4030002@cogentembedded.com>
References: <201306080351.39018.sergei.shtylyov@cogentembedded.com> <51B2765D.7030604@cogentembedded.com> <51B277A7.4010709@cogentembedded.com> <20130607.233915.1771016084489204040.davem@davemloft.net> <51B32D76.1030507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org, horms@verge.net.au,
	nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org,
	magnus.damm@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <51B32D76.1030507@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08-06-2013 17:11, Sergei Shtylyov wrote:

>>>>>      This series of 9 patches are against Dave's 'net-next.git'
>>>>> repository.
>>>>>      The series deals with the #ifdef'fery around SoC support
>>>>> code/data in
>>>>>      the
>>>>> 'sh_eth' driver. It doesn't yet get rid of all the #ifdef's: 3 are
>>>>> left, 1 of
>>>>> them still hinders ARM multiplatform build -- I'll try to deal with it
>>>>> next
>>>>> week.

>>>>> [1/9] sh_eth: create initial ID table
>>>>> [2/9] sh_eth: get SH771x support out of #ifdef
>>>>> [3/9] sh_eth: get SH7619 support out of #ifdef
>>>>> [4/9] sh_eth: get R8A7740 support out of #ifdef
>>>>> [5/9] sh_eth: get SH77{34|63} support out of #ifdef
>>>>> [6/9] sh_eth: get SH7757 support out of #ifdef
>>>>> [7/9] sh_eth: get SH7724 support out of #ifdef
>>>>> [8/9] sh_eth: get R8A777x support out of #ifdef
>>>>> [9/9] sh_eth: remove dependencies from Kconfig

>>>>     Sorry, Paul, forgot to include you into the CC list on most of the
>>>>     patches
>>>> and the cover letter. Please look for the patches on linux-sh and ACK
>>>> them
>>>> if you deem necessary.

>>>     Also, forgot to CC Simon, Magnus, Russell and LAKML on some patches.
>>> Too much haste, forgot to run scripts/get_maintainer.pl before sending
>>> out patches...

>> I'll apply this solely because it finally allows me to build test this
>> driver on x86-64.

>     Hold on please. It just occured to me that the series won't be
> bisectable on anything but R-Car CPUs (I checked it only on R8A7779)
> since I forgot that 'sh_eth_my_cpu_data' variable should be always
> available in any configuuration until the last patch (so the patch #1 is
> somewhat incomplete). I'll respin the series today and resend.

    Oh, you've already applied it! Well, at least the result is 
buildable on all arches. :-)
    You're sometimes too quick though. :-)

WBR, Sergei

