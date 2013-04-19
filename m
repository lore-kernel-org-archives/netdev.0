From: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH wireless-next V2] rt2x00: Use more
 current logging styles, shrink object size
Date: Fri, 19 Apr 2013 20:29:56 +0200
Message-ID: <51718D24.3020902@gmail.com>
References: <1366360406.3901.10.camel@joe-AO722>
	<CAL1gcdOMtbzxCVLNvDK_CD-M+_SdAeL3Sja9khO9+G2bNOCz1g@mail.gmail.com>
	<1366365149.3901.15.camel@joe-AO722>
	<1366385620.3901.28.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	rt2x00 Users List <users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
In-Reply-To: <1366385620.3901.28.camel@joe-AO722>
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

On 04/19/13 17:33, Joe Perches wrote:
> Reduce object space ~2% using more current logging styles.
> 
> Neaten and simplify logging macros.
> Use wiphy_<level> where appropriate.
> Coalesce formats.
> 
> Convert ERROR/WARNING/INFO macros to rt2x00_<level>
> Convert EEPROM to rt2x00_eeprom_dbg
> Convert PROBE_ERROR to rt2x00_probe_err
> Convert DEBUG to rt2x00_dbg
> Convert EEPROM to rt2x00_eeprom_dbg
> 
> $ size drivers/net/wireless/rt2x00/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>  245639	  71696	  69584	 386919	  5e767	drivers/net/wireless/rt2x00/built-in.o.new
>  240609	  70096	  68944	 379649	  5cb01	drivers/net/wireless/rt2x00/built-in.o.new.nodyndbg
>  240609	  70096	  68944	 379649	  5cb01	drivers/net/wireless/rt2x00/built-in.o.new.no_rt2x00_debug
>  249198	  70096	  70352	 389646	  5f20e	drivers/net/wireless/rt2x00/built-in.o.old
>  249198	  70096	  70352	 389646	  5f20e	drivers/net/wireless/rt2x00/built-in.o.old.nodyndbg
>  244222	  70096	  69712	 384030	  5dc1e	drivers/net/wireless/rt2x00/built-in.o.old.no_rt2x00_debug
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Acked-by: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
> V2 differences:
> 
> Correct copy/paste error in rt2x00_info/warn macros
> Reorder macro definitions
> Use embedded prefix in rt2x00_eeprom_dbg
> 
> Object size increased from v1 ~100 bytes x86/32.
> Object size may be slightly smaller this way for x86/64
> 
>
---
Gertjan
