From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e1000 close (NAPI)
Date: Tue, 7 Oct 2003 22:58:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229702@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Robert Olsson" <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -	if(work_done < work_to_do) {
> +	if(work_done < work_to_do || !netif_running(netdev)) {
>  		netif_rx_complete(netdev);
>  		e1000_irq_enable(adapter);
>  	}

Is e1000 unique in this regard, or do the other NAPI-enabled drivers
have the same issue?

-scott
