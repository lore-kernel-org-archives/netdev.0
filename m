From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: ethernet : stmicro: fixed power suspend and resume
 failure in stmmac driver
Date: Thu, 16 Oct 2014 10:58:22 +0200
Message-ID: <543F88AE.2020702@st.com>
References: <1412056534-7995-1-git-send-email-hliang1025@gmail.com>	<20140930.151056.950254777090461575.davem@davemloft.net>	<CAPig_t=oA6BuAt77DDsLqrtRBDbV_vsoAxM31XxLjkAFpYG1-Q@mail.gmail.com> <20141001.134508.1301867654128829684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<adi-linux-docs@lists.sourceforge.net>
To: <hliang1025@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141001.134508.1301867654128829684.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Hao Liang

On 10/1/2014 7:45 PM, David Miller wrote:
> From: Hao Liang <hliang1025@gmail.com>
> Date: Wed, 1 Oct 2014 14:08:28 +0800
>
>> I double-check my patch and the ->mac->xxx calls are still under the lock.
>> I think that lock is trying to protect priv struct and related data, so i
>> just remove some functions have no bearing on priv struct.
>
> It's preventing parallel invocations of the ->mac->xxx calls.
>
> The other instances are in device open/close, where RTNL semaphore is
> held, and no other code paths in the driver can be active.
>
> You need the lock.

Do you have a new patch for this problem after David's advice?

I am reviewing the patches sent some weeks ago for driver looking
and I can also try to fix this in case of you have no news.

Let me know,

Regards,
peppe
