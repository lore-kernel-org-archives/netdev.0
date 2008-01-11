From: "Joonwoo Park" <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [ipw3945-devel] [PATCH 4/5] iwlwifi: iwl3945 eliminate sleepable task queue from context
Date: Fri, 11 Jan 2008 10:38:59 +0900
Message-ID: <b25c3fa70801101738j512a6189i3e4541bf0348b91f@mail.gmail.com>
References: <11998765783953-git-send-email-joonwpark81@gmail.com>
	 <1200013607.3530.128.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "Zhu Yi" <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1200013607.3530.128.camel-F7Q/YMNgnyhhZnBKgDE8z0EOCMrvLtNR@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2008/1/11, Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>:
> Hi Joonwoo,
>
> We already did something similiar in our code base. Could you please
> take a look at this patch?
>
> http://intellinuxwireless.org/repos/?p=iwlwifi.git;a=commitdiff;h=57aa02255e9d7be5e2494683fc2793bd1d0707e2
>
> Thanks,
> -yi

Ooops :-)
I should have checked code base, it's my fault.
it's seems very similar, but I could not made build unfortunately.
Can you introduce to me how to build it please?

my build error is here:
jason@ehus ~/SRC/DRIVERS/iwlwifi $ KSRC=/home/jason/SRC/LINUX/linux-2.6 make
make -C /home/jason/SRC/LINUX/linux-2.6 O=
M=/home/jason/SRC/DRIVERS/iwlwifi/compatible/
EXTRA_CFLAGS="-DCONFIG_IWL3945_DEBUG=y -DCONFIG_IWL4965_DEBUG=y
-DCONFIG_IWL3945_SPECTRUM_MEASUREMENT=y
-DCONFIG_IWL4965_SPECTRUM_MEASUREMENT=y -DCONFIG_IWL4965_SENSITIVITY=y
-DCONFIG_IWL3945_QOS=y -DCONFIG_IWL4965_QOS=y" modules
make[1]: Entering directory `/home/jason/SRC/LINUX/linux-2.6'
  CC [M]  /home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.o
In file included from
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:51:
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl-3945.h:443: error:
expected specifier-qualifier-list before 'ieee80211_key_alg'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c: In function
'iwl3945_add_station':
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:539: error:
implicit declaration of function 'MAC_ARG'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:539:
warning: too few arguments for format
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c: In function
'iwl3945_commit_rxon':
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:1161:
warning: too few arguments for format
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c: In function
'iwl3945_update_sta_key_info':
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:1400: error:
'struct iwl3945_hw_key' has no member named 'alg'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:1401: error:
'struct iwl3945_hw_key' has no member named 'keylen'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:1402: error:
'struct iwl3945_hw_key' has no member named 'key'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:1402: error:
'struct iwl3945_hw_key' has no member named 'key'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c: In function
'iwl3945_build_tx_cmd_hwcrypto':
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:2594: error:
'struct iwl3945_hw_key' has no member named 'alg'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:2597: error:
'struct iwl3945_hw_key' has no member named 'keylen'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:2597: error:
'struct iwl3945_hw_key' has no member named 'key'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:2597: error:
'struct iwl3945_hw_key' has no member named 'keylen'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:2597: error:
'struct iwl3945_hw_key' has no member named 'key'
/home/jason/SRC/DRIVERS/iwlwifi/compatible/iwl3945-base.c:2597: error:
'struct iwl3945_hw_key' has no member named 'keylen'


Thanks,
Joonwoo
