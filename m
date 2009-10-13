From: Kevin Dawson <kevind@esi.com.au>
Subject: Re: [PATCH] ax25: unsigned cannot be less than 0 in ax25_ctl_ioctl()
Date: Wed, 14 Oct 2009 08:50:15 +1100
Message-ID: <4AD4F617.4090300@cerebellum.kd>
References: <4AD0FB0B.8050609@gmail.com> <4AD34D3C.1060206@bfs.de> <4AD37D44.9050207@gmail.com> <4AD3A67B.6070703@cerebellum.kd> <4AD44CF6.1070801@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: wharms@bfs.de
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4AD44CF6.1070801@bfs.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

walter harms wrote:
> 
> Kevin Dawson schrieb:
>> 
>>     if (ax25_ctl.arg > ULONG_MAX / HZ && ...
> 
> i like this because it prevents a wrap around for stupid ax25_ctl.arg values but will not help when
> ax25_ctl.arg * HZ is used later. NTL i think HZ does not need to be constant these days but i am not an
> expert on that area.

I don't have a kernel source tree at the moment, so I haven't seen where 
it's used, but the same size-limiting principle using divisions would 
apply whether you have constants, variables or function calls.

If ax25_ctl.arg * HZ is used later, one should arrange that the thread 
won't get that far if it has already been deemed an excessive value.

Kevin
