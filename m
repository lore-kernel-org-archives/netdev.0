From: Ian Kumlien <ian.kumlien@gmail.com>
Subject: Re: [PATCH] Update pptp handling to avoid null pointer deref.
Date: Mon, 2 Jan 2017 09:05:37 +0100
Message-ID: <CAA85sZsZeLYC8smbTCzKo3-2TrNSVL0aZ8LOq5xegcqqReJD8A@mail.gmail.com>
References: <20170101231936.5905-1-ian.kumlien@gmail.com> <20170101.230753.2076894379858224939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170101.230753.2076894379858224939.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 2, 2017 at 5:07 AM, David Miller <davem@davemloft.net> wrote:
> From: Ian Kumlien <ian.kumlien@gmail.com>
> Date: Mon,  2 Jan 2017 00:19:36 +0100
>
>> __skb_flow_dissect can be called with a skb or a data packet, either
>> can be NULL. All calls seems to have been moved to __skb_header_pointer
>> except the pptp handling which is still calling skb_header_pointer.
>>
>> skb_header_pointer will use skb->data and thus:
>  ...
>> ---
>>
>> Signed-off-by: Ian Kumlien <ian.kumlien@gmail.com>
>
> You need to fix some parts of your submission.
>
> Do not put the signoff after the "---", git will remove all text
> after that "---" from the commit message.

Sorry, I tend to do that automatically

> You must include a proper "Fixes: " tag which indicates which change
> introduced this regression.  This is critical for analyzing your fix
> and also for figuring out which -stable releases your fix should be
> backported to.

I it's supposed to be added after 4.7 but i can't find it in 4.8, will
send it as a stable patch for 4.9

> In this case the guilty commit is ab10dccb1160 ("rps: Inspect PPTP
> encapsulated by GRE to get flow hash")

Thanks, =)

Now patch is incomming
