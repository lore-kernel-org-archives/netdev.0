From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [patch 3/8 2.5] e1000 -  Fix MODULE_PARM, module_param and
	module_param_array usage
Date: Fri, 17 Sep 2004 19:59:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095476353.3496.8.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0409170231510.15233-100000@isotope.jf.intel.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0409170231510.15233-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-09-17 at 02:57, Ganesh Venkatesan wrote:
> @@ -306,5 +312,9 @@ e1000_check_options(struct e1000_adapter
>  		       "Warning: no configuration for board #%i\n", bd);
>  		DPRINTK(PROBE, NOTICE, "Using defaults for all values\n");
>  #ifndef module_param_array
> -		bd = E1000_MAX_NIC;
>  #endif
>  	}

Is that leaving an empty #ifndef/#endif ?

-scott
