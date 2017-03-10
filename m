From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 1/8] net: bcmgenet: correct the RBUF_OVFL_CNT and
 RBUF_ERR_CNT MIB values
Date: Thu, 9 Mar 2017 17:42:46 -0800
Message-ID: <e798c012-185b-0e1e-ca9b-3094f354a2d1@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
 <20170310005850.10808-2-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-2-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 04:58 PM, Doug Berger wrote:
> The location of the RBUF overflow and error counters has moved between
> different version of the GENET MAC.  This commit corrects the driver to
> read from the correct locations depending on the version of the GENET
> MAC.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
