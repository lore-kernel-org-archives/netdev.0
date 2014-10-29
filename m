From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] wireless: rt2x00: add new rt2800usb
	device
Date: Wed, 29 Oct 2014 12:48:46 +0100
Message-ID: <20141029114846.GC2021@redhat.com>
References: <1414510961-28920-1-git-send-email-kibi@debian.org>
	<20141029110214.GB2021@redhat.com>
	<20141029111224.GC29720@mraw.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Cyril Brulebois <kibi-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141029111224.GC29720-xazfMhTT2R0@public.gmane.org>
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

On Wed, Oct 29, 2014 at 12:12:24PM +0100, Cyril Brulebois wrote:
> Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (2014-10-29):
> > On Tue, Oct 28, 2014 at 04:42:41PM +0100, Cyril Brulebois wrote:
> > > 0x1b75 0xa200 AirLive WN-200USB wireless 11b/g/n dongle
> > > 
> > > References: https://bugs.debian.org/766802
> > > Reported-by: Martin Mokrejs <mmokrejs-08dBlVkRsZWoiTQjSSYKZesEoJ4y9sgM@public.gmane.org>
> > 
> > Was this patch tested by reporter? I would rather see Reported-and-tested-by tag :-)
> 
> The reporter confirmed the following trick worked:
> 
>   # echo rt2800usb >> /etc/modules
>   # echo 'install rt2800usb /sbin/modprobe --ignore-install rt2800usb $CMDLINE_OPTS && echo 1b75 a200 > /sys/bus/usb/drivers/rt2800usb/new_id' > /etc/modprobe.d/ralink.conf
>   # modprobe -r rt2800usb ; modprobe rt2800usb

Ok, that's fine .

Acked-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
