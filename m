From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 2/2 V2] staging: r8188eu: Fix case where ethtype was
 never obtained and always be checked against 0
Date: Thu, 17 Apr 2014 02:41:07 +0300
Message-ID: <20140416234107.GT26890@mwanda>
References: <1397677774-20283-1-git-send-email-Larry.Finger@lwfinger.net>
 <1397677774-20283-2-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 Stable <stable@vger.kernel.org>, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1397677774-20283-2-git-send-email-Larry.Finger@lwfinger.net>
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

On Wed, Apr 16, 2014 at 02:49:34PM -0500, Larry Finger wrote:
>  	if (auth_alg == 2) {
> +		/* get ether_type */
> +		ptr = ptr + pfhdr->attrib.hdrlen + LLC_HEADER_SIZE;
> +		memcpy(&ether_type, ptr, 2);
> +		ether_type = ntohs((unsigned short)ether_type);

The incorrect cast here introduces a new sparse warning.

https://lwn.net/Articles/205624/

regards,
dan carpenter
