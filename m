From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ehea: Fix kernel deadlock in DLPAR-mem processing
Date: Wed, 16 Jun 2010 18:05:47 -0700 (PDT)
Message-ID: <20100616.180547.200372207.davem@davemloft.net>
References: <201006151735.43144.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, tklein@linux.ibm.com,
	adetsch@br.ibm.com, themann@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201006151735.43144.ossthema@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Date: Tue, 15 Jun 2010 17:35:42 +0200

> Port reset operations and memory add/remove operations need to 
> be serialized to avoid a kernel deadlock. The deadlock is caused
> by calling the napi_disable() function twice.
> Therefore we have to employ the dlpar_mem_lock in the ehea_reset_port
> function as well
> 
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

Applied.
