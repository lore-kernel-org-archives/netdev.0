From: Patrick McHardy <kaber@trash.net>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: Tue, 07 Dec 2004 18:23:46 +0100
Message-ID: <41B5E722.2080600@trash.net>
References: <1102380430.6103.6.camel@buffy> <20041206224441.628e7885.akpm@osdl.org> <1102422544.1088.98.camel@jzny.localdomain> <41B5E188.5050800@trash.net> <20041207170748.GF1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Andrew Morton <akpm@osdl.org>,
        Thomas Cataldo <tomc@compaqnet.fr>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041207170748.GF1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>* Patrick McHardy <41B5E188.5050800@trash.net> 2004-12-07 17:59
>  
>
>>That's also what I thought at first. But the problem is in
>>tcf_action_copy_stats, it assumes a->priv has the same layout as
>>struct tcf_act_hdr, which is not true for struct tcf_police. This
>>patch rearranges struct tcf_police to match tcf_act_hdr.
>>    
>>
>
>Hehe, see my post a few minutes back. I came up with nearly the same
>solution ;-> The only difference to my patch is that I don't touch
>tcf_police if the action code isn't compiled.
>  
>
Either one is fine with me, although I would prefer to see
the number of ifdefs in this area going down, not up :)

Regards
Patrick
