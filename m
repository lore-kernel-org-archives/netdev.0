From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH 2/2] Add a netlink attribute INET_DIAG_SECCTX
Date: Mon, 5 Sep 2011 08:32:33 +0800
Message-ID: <4E6418A1.9000002@windriver.com>
References: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com> <2593215.lUI7et83Qv@sifl> <4E5F5153.6070708@windriver.com> <1971656.b979ahlREa@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1971656.b979ahlREa@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/01/2011 08:28 PM, Paul Moore wrote:
> On Thursday, September 01, 2011 05:33:07 PM Rongqing Li wrote:
>> On 09/01/2011 05:18 AM, Paul Moore wrote:
>>> On Wednesday, August 31, 2011 04:36:17 PM rongqing.li@windriver.com wrote:
>>>> From: Roy.Li<rongqing.li@windriver.com>
>>>>
>>>> Add a new netlink attribute INET_DIAG_SECCTX to dump the security
>>>> context of TCP sockets.
>>>
>>> You'll have to forgive me, I'm not familiar with the netlink code used
>>> by
>>> netstat and friends, but is there anyway to report back the security
>>> context of UDP sockets?  Or does the code below handle that already?
>>>
>>> In general, AF_INET and AF_INET6 sockets, regardless of any upper level
>>> protocols, have security contexts associated with them and it would be
>>> nice to see them in netstat.
>>
>> Yes, this is real concern, If the dumping tcp security context can be
>> accepted by netdev, I am planning to implement it for ipv4 udp socket, unix
>> socket. then ipv6..
>
> Great, I'm glad to hear you're planning on implementing this for more than
> just TCP.
>
> I understand your desire to have the basic idea accepted with only TCP
> implemented - and that is fine with me - but I would like to see support for
> all of the protocols merged at the same time.  In other words, seeking the
> basic ACKs for TCP from the davem, et al is okay but I'd like to defer merging
> TCP support until you have everything implemented and ready to be merged.
>

Ok, I will try

-- 
Best Reagrds,
Roy | RongQing Li
