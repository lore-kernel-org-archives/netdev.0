From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] [net-next] stmmac: use netif_set_real_num_{rx,tx}_queues
Date: Tue, 4 Apr 2017 08:15:48 +0200
Message-ID: <cf125933-2def-9fac-56d2-d3cf9d7e0bbe@st.com>
References: <20170328094856.3457886-1-arnd@arndb.de>
 <20170328.180105.1996071259325891752.davem@davemloft.net>
 <20170330074536.GA4814@Red> <20170330143435.GA28098@ulmo.ba.sec>
 <51947833-7559-0794-911d-d9cac65c5065@axis.com>
 <059fcede-1b71-a074-39c3-4993b0e0bc08@synopsys.com>
 <799c7a4b-767e-b21c-d3bf-8fd3b639d70f@st.com>
 <21934325-6d37-7aea-793f-71fac2c40bf3@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <arnd@arndb.de>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Thierry Reding <treding@nvidia.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21934325-6d37-7aea-793f-71fac2c40bf3@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Joao

On 4/3/2017 3:12 PM, Joao Pinto wrote:
> Yes older cores do not support multiple queues and I tried to isolate the
> features not to affect older versions.

ok so we are inline ;-)

>
> Do you think that functions as "ndev = alloc_etherdev_mqs" has some sort of
> influence?

I do not think so is we are passing the right txqs and rxqs values.

Regards
Peppe

>
> Thanks.
