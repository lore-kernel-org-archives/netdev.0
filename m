From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Fri, 07 Sep 2012 15:08:44 +0200
Message-ID: <1800340.RWjbMaZGSN@linux-lqwf.site>
References: <2791550.LhGu6po6Xy@linux-lqwf.site> <1446113.XC2Qbo4flT@linux-lqwf.site> <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA5741E@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA5741E-8ZTw5gFVCTjVH5byLeRTJxkTb7+GphCuwzqs5ZKRSiY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 07 September 2012 14:01:23 Alexey ORISHKO wrote:
> The experience from early implementations and prototyping of NCM was that
> using NCM with 4-8kB NTB increased max throughput in loop-mode by a factor
> of 5-6 even 8-10 times compared to using ECM. One real-world example was
> modem for 21+6Mbit/s what used 100% CPU with ECM responsible for approx. 40%
> of the MIPS used. Using NCM instead CPU was only at approx. 65% utilization.
> Which allowed multiple other functions to be added and significantly increased
> the usability and value of the modem.
> 
> NCM efficiency is gained either by accessing TX queue of upper layer or
> by using timer. 
> 
> These findings were later confirmed by multiple major industry players
> (names withheld), and demonstrated during multiple NCM interoperability
> workshops using multiple device HW platforms, multiple operating systems
> and multiple host HW ranging from Beagleboard to latest quad-core x86.    
> 
> Until we do something with network device framework in order to get access
> to upper layer Tx queue we need to utilize timer.

Could you explain your reasoning? From what you say we must reduce the number
of transfers, thus use them efficiently, but why by means of a timer?

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
