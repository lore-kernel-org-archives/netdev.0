From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2 18/18] RDS: IB: add missing connection cache
 usage info
Date: Wed, 7 Dec 2016 09:20:17 -0800
Message-ID: <6159757e-c799-ee7f-0ee0-c9b3534a4237@oracle.com>
References: <1481083316-11648-19-git-send-email-santosh.shilimkar@oracle.com>
 <20161207.105531.1347292514118544125.davem@davemloft.net>
 <eac62d66-7a41-965d-8ecb-c2e4b651c39d@oracle.com>
 <20161207.120536.1153607792891600896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207.120536.1153607792891600896.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/7/2016 9:05 AM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Wed, 7 Dec 2016 08:44:04 -0800
>
>> On 12/7/2016 7:55 AM, David Miller wrote:
>>> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>>> Date: Tue,  6 Dec 2016 20:01:56 -0800
>>>
>>> What level of compatability exists here?  If we run an old tool on a
>>> new
>>> kernel, or a new tool on an old kernel, does it work properly?
>>>
>> Tools repo carries a copy of the header and thats how the old tool and
>> new tools have been running with older/newer kernels. There are few
>> more
>> bits left before I can start using directly kernel header for newer
>> tools.
>>
>> Moreover this particular parameter is only used for verbose mode which
>> isn't used in default options.
>
> That doesn't really answer my question, I think.
>
Sorry for not being clear.

> Are you saying that one is required to run old tools on old kernels,
> and new tools on new kernels, and that's how you have this setup in
> your repo?
>
No.

> If so, that really isn't acceptable.  Both old and new tools must work
> with all kernel versions.
>
Older version of tools works on either kernel versions. Older tools
don't parse this additional info since its copy of header not
carrying some of these extra verbose fields. Newer/Updated tools which
can parse this extra info in needs newer or an updated kernel which
supports and populates these fields.

As mentioned, this particular option used only in verbose mode so
am ok to drop this change if its still a concern.

Regards,
Santosh
