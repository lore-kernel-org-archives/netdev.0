From: Anton Nayshtut <Anton.Nayshtut@Wilocity.com>
Subject: Re: [PATCH 1/4] bonding: L2DA mode added
Date: Mon, 25 Nov 2013 11:10:54 +0200
Message-ID: <5293141E.5090202@Wilocity.com>
References: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>
 <1385045738-29726-2-git-send-email-Anton.Nayshtut@wilocity.com>
 <1385047978.10637.51.camel@edumazet-glaptop2.roam.corp.google.com>
 <528E28D7.4010306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Eric Dumazet <edumazet@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Erez Kirshenbaum <Erez.Kirshenbaum@Wilocity.com>,
	Boris Lapshin <Boris.Lapshin@Wilocity.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <528E28D7.4010306@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric, Nik, Andy,

Thanks for your comments.

I'll investigate the override option approach first, and then will
re-implement the patch using RCU with corresponding
Documentation/networking/bonding.txt changes, if still needed.

P.S. Sorry for delay with my reply. It was caused by personal reasons.

Best Regards,
Anton

On 21/11/2013 17:37, Nikolay Aleksandrov wrote:
> On 11/21/2013 04:32 PM, Eric Dumazet wrote:
>> On Thu, 2013-11-21 at 16:55 +0200, Anton Nayshtut wrote:
>>> This patches introduces L2DA bonding module with all the data structures and
>>> interfaces. It's not integrated yet.
>>
>> I veto any kind of new bonding mode not using RCU.
>>
>> Adding another rwlock in 2013 is simply not an option.
>>
>> Thanks
>>
>>
> +1
> Also,
> I haven't read the patch-set closely but based on the description in the first
> patch I think you can already get this (or very similar) functionality by using
> the slave override option in the bonding. You can match the destination L2
> address and override the slave based on that.
> 
> Nik
> 
