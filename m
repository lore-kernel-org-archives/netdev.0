From: Amos Jeffries <squid3@treenet.co.nz>
Subject: Re: [PATCH v2 9/9] tproxy: use the interface primary IP address as
 a default value for --on-ip
Date: Fri, 22 Oct 2010 03:26:31 +1300
Message-ID: <4CC04D97.9020105@treenet.co.nz>
References: <20101021104709.5192.31249.stgit@este.odu> <20101021104710.5192.65152.stgit@este.odu> <4CC04C81.9080504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@balabit.hu>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CC04C81.9080504@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/10/10 03:21, Patrick McHardy wrote:
> Am 21.10.2010 12:47, schrieb KOVACS Krisztian:
>> From: Balazs Scheidler<bazsi@balabit.hu>
>>
>> The REDIRECT target and the older TProxy versions used the primary address
>> of the incoming interface as the default value of the --on-ip parameter.
>> This was unintentionally changed during the initial TProxy submission and
>> caused confusion among users.
>>
>> Since IPv6 has no notion of primary address, we just select the first address
>> on the list: this way the socket lookup finds wildcard bound sockets
>> properly and we cannot really do better without the user telling us the
>> IPv6 address of the proxy.
>>
>> This is implemented for both IPv4 and IPv6.
>
>
> Also applied, thanks a lot.
>

Hoooray!! Thanks very, very, very much.

Just one followup question:
   which kernel and iptables release is this now headed for?

AYJ
