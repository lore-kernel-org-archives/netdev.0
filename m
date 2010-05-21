From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the driver-core tree with the net
 tree
Date: Thu, 20 May 2010 23:50:08 -0700 (PDT)
Message-ID: <20100520.235008.97331614.davem@davemloft.net>
References: <20100521162134.6b6326bd.sfr@canb.auug.org.au>
	<m1tyq1wy4h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, greg@kroah.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, therbert@google.com,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1tyq1wy4h.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 20 May 2010 23:46:22 -0700

> It looks right, except perhaps the RPS code looks like it will cause a
> build failure with sysfs disabled, but that has nothing to do with your
> changes.

CONFIG_RPS depends upon CONFIG_SMP && CONFIG_SYSFS, so no that build
failure is not possible.
