From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH net] qed: fix old-style function definition
Date: Fri, 16 Dec 2016 09:55:50 +0100
Message-ID: <20161216085550.GA3840@linux-x5ow.site>
References: <20161216084808.1815139-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com, Arun Easi <arun.easi@cavium.com>,
        Hannes Reinecke <hare@suse.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161216084808.1815139-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 09:47:41AM +0100, Arnd Bergmann wrote:
> The newly added file causes a harmless warning, with "make W=1":
> 
> drivers/net/ethernet/qlogic/qed/qed_iscsi.c: In function 'qed_get_iscsi_ops':
> drivers/net/ethernet/qlogic/qed/qed_iscsi.c:1268:29: warning: old-style function definition [-Wold-style-definition]
> 
> This makes it a proper prototype.
> 
> Fixes: fc831825f99e ("qed: Add support for hardware offloaded iSCSI.")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---

Looks good,
Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>

-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
