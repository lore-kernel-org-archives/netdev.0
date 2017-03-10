From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 5/8] net: bcmgenet: synchronize irq0 status between
 the isr and task
Date: Thu, 9 Mar 2017 17:44:16 -0800
Message-ID: <1dd923cf-40b7-421c-41ae-c5b18a44677a@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
 <20170310005850.10808-6-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-6-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 04:58 PM, Doug Berger wrote:
> Add a spinlock to ensure that irq0_stat is not unintentionally altered
> as the result of preemption.  Also removed unserviced irq0 interrupts
> and removed irq1_stat since there is no bottom half service for those
> interrupts.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
