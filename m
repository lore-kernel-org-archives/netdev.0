From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 1/2] rt2800usb:fix efuse detection
Date: Fri, 13 Jun 2014 15:10:02 +0200
Message-ID: <20140613131001.GB2211@redhat.com>
References: <20140612173057.15935.14194.stgit@charlie.fem.tu-ilmenau.de>
	<20140612173336.15935.17359.stgit@charlie.fem.tu-ilmenau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140612173336.15935.17359.stgit-T1IWWRiYoUTeQ37wNh6nHvMwkO6i8y0ws0AfqQuZ5sE@public.gmane.org>
List-Unsubscribe: <http://rt2x00.serialmonkey.com/mailman/options/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=unsubscribe>
List-Archive: <http://rt2x00.serialmonkey.com/pipermail/users_rt2x00.serialmonkey.com/>
List-Post: <mailto:users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Help: <mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=help>
List-Subscribe: <http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=subscribe>
Errors-To: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
Sender: "users" <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, Jun 12, 2014 at 07:33:36PM +0200, Michael Braun wrote:
> The device 057c:8501 (AVM Fritz! WLAN v2 rev. B) currently does not
> load. One thing observed is that the vendors driver detects EFUSE mode
> for this device, but rt2800usb does not. This is due to rt2800usb
> lacking a check for the firmware mode present in the vendors driver,
> that this patch adopts for rt2800usb.
> 
> With this patch applied, the 'RF chipset' detection does no longer fail.
> 
> Signed-off-by: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Acked-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
