From: yalin wang <yalin.wang2010@gmail.com>
Subject: Re: [PATCH v2 Resend] net/fddi: remove HWM_REVERSE() macro
Date: Tue, 11 Aug 2015 13:50:56 +0800
Message-ID: <03416E4A-6121-41C4-B209-AD60308FE317@gmail.com>
References: <1FEC219B-7AF2-47C9-8EBB-786EE6EADCE4@gmail.com> <39055924-5AA5-4DE0-8872-D2F107EA82F1@gmail.com> <20150810.223750.1908561238664673104.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150810.223750.1908561238664673104.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Aug 11, 2015, at 13:37, David Miller <davem@davemloft.net> wrote:
> 
> From: yalin wang <yalin.wang2010@gmail.com>
> Date: Tue, 11 Aug 2015 13:11:22 +0800
> 
>> HWM_REVERSE() macro is unused, remove it.
>> 
>> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> 
> You did not do as I asked you to, this patch is still corrupted
> and there is no way you successfully applied what is in this patch.
> 
>> -#define        HWM_REVERSE(x)          ((((x)<<24L)&0xff000000L)       +       \
>> -                                (((x)<< 8L)&0x00ff0000L)       +       \
>> -                                (((x)>> 8L)&0x0000ff00L)       +       \
>> -                                (((x)>>24L)&0x000000ffL))
> 
> This indentation here is spaces, whereas in the source files they
> are TABS.
> 
> Your email client did this.
> 
> If you fail to properly verify that your outgoing patches are not
> corrupted before submitting them here, I will stop reviewing and
> considering your changes.
> 
> Thank you.
ouch,  i am sorry that i am sending from windows PC,
let me check that .
Sorry for that .