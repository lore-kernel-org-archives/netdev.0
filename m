From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 1/4] bonding: L2DA mode added
Date: Thu, 21 Nov 2013 16:37:59 +0100
Message-ID: <528E28D7.4010306@redhat.com>
References: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>	 <1385045738-29726-2-git-send-email-Anton.Nayshtut@wilocity.com> <1385047978.10637.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Erez Kirshenbaum <Erez.Kirshenbaum@wilocity.com>,
	Boris Lapshin <Boris.Lapshin@wilocity.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385047978.10637.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/21/2013 04:32 PM, Eric Dumazet wrote:
> On Thu, 2013-11-21 at 16:55 +0200, Anton Nayshtut wrote:
>> This patches introduces L2DA bonding module with all the data structures and
>> interfaces. It's not integrated yet.
> 
> I veto any kind of new bonding mode not using RCU.
> 
> Adding another rwlock in 2013 is simply not an option.
> 
> Thanks
> 
> 
+1
Also,
I haven't read the patch-set closely but based on the description in the first
patch I think you can already get this (or very similar) functionality by using
the slave override option in the bonding. You can match the destination L2
address and override the slave based on that.

Nik
