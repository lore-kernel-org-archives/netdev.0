From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] SECURITY ISSUE with connector
Date: Fri, 02 Oct 2009 09:57:24 -0700 (PDT)
Message-ID: <20091002.095724.12562070.davem@davemloft.net>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
	<20091002135859.GA9383@kroah.com>
	<200910021754.12940.philipp.reisner@linbit.com>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev-devel@lists.sourceforge.net, greg@kroah.com,
	linux-kernel@vger.kernel.org, dm-devel@redhat.com,
	netdev@vger.kernel.org, zbr@ioremap.net, akpm@linux-foundation.org
To: philipp.reisner@linbit.com
Return-path: <dm-devel-bounces@redhat.com>
In-Reply-To: <200910021754.12940.philipp.reisner@linbit.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Philipp Reisner <philipp.reisner@linbit.com>
Date: Fri, 2 Oct 2009 17:54:12 +0200

> Think of the connector as a layer on top of netlink that allows more
> than a hard coded number of subsystems to use netlink.

There are no such limits in netlink, we have 'genetlink' which allows
an arbitrary number of subsystems to use netlink.

What connector provides over netlink/genetlink is something different
altogether.
