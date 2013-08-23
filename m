From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net-next 10/10] staging: vt6656: inherit addr_assign_type
 along with dev_addr
Date: Fri, 23 Aug 2013 14:15:00 +0300
Message-ID: <20130823111500.GC4713@mwanda>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
 <1377250513-3662-11-git-send-email-bjorn@mork.no>
 <20130823100333.GT22811@mwanda> <87y57s3cpa.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Forest Bond <forest@alittletooquiet.net>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <87y57s3cpa.fsf@nemi.mork.no>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Ah...  Here is the first patch which adds eth_hw_addr_inherit()

http://patchwork.ozlabs.org/patch/269365/

I don't think we've actually set dst->addr_len yet at this point so
it doesn't do the memcpy().  This doesn't work.

regards,
dan carpenter
