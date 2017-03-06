From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] mac80211: Use setup_timer instead of init_timer
Date: Mon, 6 Mar 2017 13:35:10 +0100
Message-ID: <7545a8ad-ec74-ed01-d84d-9ef4528b21df@suse.cz>
References: <20170303124535.30125-1-jslaby@suse.cz>
 <1488803104.5761.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        =?UTF-8?Q?Ond=c5=99ej_Lyson=c4=9bk?= <ondrej.lysonek@seznam.cz>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488803104.5761.6.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/06/2017, 01:25 PM, Johannes Berg wrote:
> On Fri, 2017-03-03 at 13:45 +0100, Jiri Slaby wrote:
>> From: Ondřej Lysoněk <ondrej.lysonek@seznam.cz>
>>
>> Use setup_timer() and setup_deferrable_timer() to set the data and
>> function timer fields. It makes the code cleaner and will allow for
>> easier change of the timer struct internals.
> 
> Btw, I suspect you generated this with coccinelle and didn't put enough
> "..." there, because you missed one in mesh_path_new() :)

Not really. This is one of assignments for students I lead, so this is
done by hand every end of winter semester (Note the From line.)

> Care to send a patch for that one too?

I am just a forwarder, he received this request too, so you can try to
persuade him :).

thanks,
-- 
js
suse labs
