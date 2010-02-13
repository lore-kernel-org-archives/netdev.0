From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v3 3/3] net: TCP thin dupack
Date: Sat, 13 Feb 2010 16:50:42 +0100
Message-ID: <4B76CA52.9020507@simula.no>
References: <4B73F31F.9000204@simula.no> <m16361ubly.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m16361ubly.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13. feb. 2010 03:13, Eric W. Biederman wrote:
> Andreas Petlund <apetlund@simula.no> writes:
> 
>> Major changes:
>>       -Possible to disable mechanisms by socket option
>>       -Socket option value boundary check
>>
>>
>> Signed-off-by: Andreas Petlund <apetlund@simula.no>
>> ---
>>  include/linux/sysctl.h     |    1 +
>>  include/linux/tcp.h        |    4 +++-
>>  include/net/tcp.h          |    1 +
>>  net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>>  net/ipv4/tcp.c             |    7 +++++++
>>  net/ipv4/tcp_input.c       |   11 +++++++++++
>>  6 files changed, 30 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
>> index d840d75..ded3f20 100644
>> --- a/include/linux/sysctl.h
>> +++ b/include/linux/sysctl.h
>> @@ -426,6 +426,7 @@ enum
>>  	NET_TCP_MAX_SSTHRESH=124,
>>  	NET_TCP_FRTO_RESPONSE=125,
>>  	NET_TCP_FORCE_THIN_LINEAR_TIMEOUTS=126,
>> +	NET_TCP_FORCE_THIN_LINEAR_DUPACK=127,
> 
> There is no need to allocate a binary sysctl here.
> 
> Eric

Thanks. I'll address this in the next iteration.

Best regrads,
Andreas
