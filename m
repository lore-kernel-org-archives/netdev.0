From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/7990: Make lance_private.name const
Date: Wed, 13 Nov 2013 03:04:15 +0300
Message-ID: <5282C1FF.2090608@cogentembedded.com>
References: <1384283649-10482-1-git-send-email-geert@linux-m68k.org>	<5282A5E1.9090501@cogentembedded.com>	<20131112.161253.601617211955537751.davem@davemloft.net>	<5282BC76.5050701@cogentembedded.com> <CAMuHMdVn6MFbXgdE_teYW10OfYBjyZsN7v2yTTAsKj0kXao7Hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVn6MFbXgdE_teYW10OfYBjyZsN7v2yTTAsKj0kXao7Hw@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2013 01:44 AM, Geert Uytterhoeven wrote:

>>>>> @@ -100,7 +100,7 @@ struct lance_init_block {
>>>>>      */
>>>>>     struct lance_private
>>>>>     {
>>>>> -        char *name;
>>>>> +        const char *name;

>>>>      Indent with tab, not spaces, please.

>>> This whole file is %99 space indentation, you really can't blame
>>> Geert for this.

>>     It's never late to fix some.

> That would be a separate patch. Care to create and send it?

    I wasn't telling you to fix all of them, just the ones you touched anyway. 
I don't see why the separate patch is needed for that.

>> And remember about checkpatch.pl which was hardly content with the patch.

> Only because checkpatch looks at the _new_ lines, and doesn't compare the
> styles of the old and new lines.

    Care to fix it? :-)

> Gr{oetje,eeting}s,

>                          Geert

WBR, Sergei
