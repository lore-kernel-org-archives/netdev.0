From: Ani Sinha <ani@arista.com>
Subject: Re: [PATCH 1/1] update ip-sysctl.txt documentation
Date: Tue, 6 Jan 2015 18:08:46 -0800
Message-ID: <CAOxq_8N4NBzvP_JBfnj3v=o9C3tPyA0X_0q3V0sm3CQiJHPTqA@mail.gmail.com>
References: <1420583625-32414-1-git-send-email-ani@arista.com> <20150106.174039.783537681001060022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: corbet <corbet@lwn.net>, Eric Dumazet <edumazet@google.com>,
	linux-doc <linux-doc@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	fruggeri <fruggeri@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150106.174039.783537681001060022.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 6, 2015 at 2:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Ani Sinha <ani@arista.com>
> Date: Tue,  6 Jan 2015 14:33:45 -0800
>
>> @@ -64,8 +64,10 @@ fwmark_reflect - BOOLEAN
>>       Default: 0
>>
>>  route/max_size - INTEGER
>> -     Maximum number of routes allowed in the kernel.  Increase
>> -     this when using large numbers of interfaces and/or routes.
>> +        Post linux kernel 3.6, this is depricated for ipv4 as route cache is no
>> +        longer used. For ipv6, this is used to limit the maximum number of ipv6
>> +        routes allowed in the kernel.  Increase this when using large numbers of
>> +        interfaces and/or routes.
>
> Please do not change the TABs into sequenes of space characters.

Fixed in the latest patch.
