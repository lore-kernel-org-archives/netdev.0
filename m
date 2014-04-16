From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/3] staging: r8188eu: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Wed, 16 Apr 2014 11:45:30 -0700
Message-ID: <20140416184530.GA5350@kroah.com>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
 <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net>
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

On Wed, Apr 09, 2014 at 11:12:59AM -0500, Larry Finger wrote:
> Zero-initializing ether_type masked that the ether type would never be
> obtained for 8021x packets and the comparition against eapol_type
> would always fail.
> 
> Reported-by: Jes Sorensen <Jes.Sorensen@redhat.com>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org>
> ---
>  drivers/staging/rtl8188eu/core/rtw_recv.c | 20 ++++++++------------
>  1 file changed, 8 insertions(+), 12 deletions(-)

Can you fix this one up and resend?  I've applied the other two in this
series now.

thanks,

greg k-h
