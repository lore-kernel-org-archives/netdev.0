From: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [2.6 patch] net/irda/: misc possible cleanups
Date: Mon, 27 Dec 2004 21:12:43 -0800
Message-ID: <20041227211243.7d05e891.davem@davemloft.net>
References: <20041215010528.GA12937@stusta.de>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <20041215010528.GA12937-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 02:05:28 +0100
Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org> wrote:

> The patch below contains the following possible cleanups:
> - make some needlessly global code static
> - remove the following unused global functions:
>   - discovery.c: irlmp_find_device
>   - ircomm/ircomm_param.c: ircomm_param_flush
>   - irda_device.c: irda_device_set_dtr_rts
>   - irda_device.c: irda_device_change_speed
>   - irda_device.c: irda_device_set_mode
>   - iriap.c: iriap_getinfobasedetails_request
>   - iriap.c: iriap_getinfobasedetails_confirm
>   - iriap.c: iriap_getobjects_request
>   - iriap.c: iriap_getobjects_confirm
>   - iriap.c: iriap_getvalue
>   - irlan_client.c: irlan_client_reconnect_data_channel
>   - irlap_frame.c: irlap_send_frmr_frame
>   - irlmp.c: irlmp_status_request
> - remove the follwong unused global variables:
>   - irnet/irnet_ppp.c: irnet_ppp_ops
>   - irsysctl.c: sysctl_compression
> - qos.c: #ifndef CONFIG_IRDA_DYNAMIC_WINDOW irlap_requested_line_capacity

Looks good, applied.  Thanks Adrian.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
