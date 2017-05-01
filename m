From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] IB/mlx5: Add port_xmit_wait to counter registers
 read
Date: Mon, 01 May 2017 16:56:35 -0400
Message-ID: <1493672195.3041.188.camel@redhat.com>
References: <20170501163008.27043-1-tim@binbash.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tim Wright <tim-r/Uwd3QrhQcqdlJmJB21zg@public.gmane.org>, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170501163008.27043-1-tim-r/Uwd3QrhQcqdlJmJB21zg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-05-01 at 17:30 +0100, Tim Wright wrote:
> Add port_xmit_wait to the error counters read by mlx5_ib_process_mad
> to
> ensure sysfs port counter provides correct value for PortXmitWait.
> Otherwise the sysfs port_xmit_wait file always contains zero.
> 
> The previous MAD_IFC implementation populated this counter, but it
> was
> removed during the migration to PPCNT for error counters (32-bit
> only).
> 
> Signed-off-by: Tim Wright <tim-r/Uwd3QrhQcqdlJmJB21zg@public.gmane.org>

Thanks, applied.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
