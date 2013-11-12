From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/7990: Make lance_private.name const
Date: Tue, 12 Nov 2013 18:16:29 -0500 (EST)
Message-ID: <20131112.181629.742226266240112179.davem@davemloft.net>
References: <20131112.161253.601617211955537751.davem@davemloft.net>
	<5282BC76.5050701@cogentembedded.com>
	<CAMuHMdVn6MFbXgdE_teYW10OfYBjyZsN7v2yTTAsKj0kXao7Hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVn6MFbXgdE_teYW10OfYBjyZsN7v2yTTAsKj0kXao7Hw@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 12 Nov 2013 23:44:06 +0100

> On Wed, Nov 13, 2013 at 12:40 AM, Sergei Shtylyov
> <sergei.shtylyov@cogentembedded.com> wrote:
>> On 11/13/2013 12:12 AM, David Miller wrote:
>>
>>>>> @@ -100,7 +100,7 @@ struct lance_init_block {
>>>>>     */
>>>>>    struct lance_private
>>>>>    {
>>>>> -        char *name;
>>>>> +        const char *name;
>>
>>
>>>>     Indent with tab, not spaces, please.
>>
>>
>>> This whole file is %99 space indentation, you really can't blame
>>> Geert for this.
>>
>>
>>    It's never late to fix some.
> 
> That would be a separate patch. Care to create and send it?
> 
>> And remember about checkpatch.pl which was hardly content with the patch.
> 
> Only because checkpatch looks at the _new_ lines, and doesn't compare the
> styles of the old and new lines.

You really should fix the line you are changing to use tabs, please respin
with this in mind, thanks.
