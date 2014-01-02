From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 31/31] staging: r8188eu: Fix smatch error
Date: Thu, 2 Jan 2014 11:44:10 +0300
Message-ID: <20140102084410.GY28413@mwanda>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
 <1387755422-11443-32-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1387755422-11443-32-git-send-email-Larry.Finger@lwfinger.net>
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

On Sun, Dec 22, 2013 at 05:37:02PM -0600, Larry Finger wrote:
> Smatch shows the following:
> 
>   CHECK   drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
> drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:1401 OnAssocReq() error: buffer overflow 'pstapriv->sta_aid' 32 <= 32
> 

This is a false positive in Smatch.  Don't do work arounds for buggy
tools.

If you have the cross function database built on the latest version of
Smatch then I think it understands the code correctly and doesn't print
a warning.

regards,
dan carpenter
