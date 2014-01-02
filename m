From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 24/31] staging: r8188eu: Additional cleanup of
 include/odm.h
Date: Thu, 2 Jan 2014 12:05:16 +0300
Message-ID: <20140102090516.GB5443@mwanda>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
 <1387755422-11443-25-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1387755422-11443-25-git-send-email-Larry.Finger@lwfinger.net>
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

On Sun, Dec 22, 2013 at 05:36:55PM -0600, Larry Finger wrote:
> --- a/drivers/staging/rtl8188eu/include/odm_interface.h
> +++ b/drivers/staging/rtl8188eu/include/odm_interface.h
> @@ -51,7 +51,7 @@ ODM_REG(DIG,_pDM_Odm)
>  
>  #define _cat(_name, _ic_type, _func)					\
>  	(								\
> -		((_ic_type) & ODM_IC_11N_SERIES) ? _func##_11N(_name) :	\
> +		(_ic_type) ? _func##_11N(_name) :			\
>  		_func##_11AC(_name)					\
>  	)

The original version of this function was more readable...  I think
_ic_type is either zero or 16?

regards,
dan carpenter
