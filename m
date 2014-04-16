From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/3] staging: r8712u: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Wed, 16 Apr 2014 11:46:41 -0700
Message-ID: <20140416184641.GA19654@kroah.com>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
 <1397059980-11942-4-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
	Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1397059980-11942-4-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 09, 2014 at 11:13:00AM -0500, Larry Finger wrote:
> Zero-initializing ether_type masked that the ether type would never be
> obtained for 8021x packets and the comparition against eapol_type
> would always fail.
> 
> Reported-by: Jes Sorensen <Jes.Sorensen@redhat.com>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org>
> ---
>  drivers/staging/rtl8712/rtl871x_recv.c | 15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)

This breaks the build :(
