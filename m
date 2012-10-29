From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: dsa/slave: Fix compilation warnings
Date: Mon, 29 Oct 2012 19:59:38 +0000
Message-ID: <1351540778.2721.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linaro-dev@lists.linaro.org>,
	<patches@linaro.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-10-29 at 22:27 +0530, Viresh Kumar wrote:
> Currently when none of CONFIG_NET_DSA_TAG_DSA, CONFIG_NET_DSA_TAG_EDSA and
> CONFIG_NET_DSA_TAG_TRAILER is defined, we get following compilation warnings:
> 
> net/dsa/slave.c:51:12: warning: 'dsa_slave_init' defined but not used [-Wunused-function]
> net/dsa/slave.c:60:12: warning: 'dsa_slave_open' defined but not used [-Wunused-function]
> net/dsa/slave.c:98:12: warning: 'dsa_slave_close' defined but not used [-Wunused-function]
> net/dsa/slave.c:116:13: warning: 'dsa_slave_change_rx_flags' defined but not used [-Wunused-function]
> net/dsa/slave.c:127:13: warning: 'dsa_slave_set_rx_mode' defined but not used [-Wunused-function]
> net/dsa/slave.c:136:12: warning: 'dsa_slave_set_mac_address' defined but not used [-Wunused-function]
> net/dsa/slave.c:164:12: warning: 'dsa_slave_ioctl' defined but not used [-Wunused-function]
> 
> Fix them by enclosing these routines under #ifdef,endif.
[...]

This is not a useful configuration.  It might make more sense to make
NET_DSA a hidden option and have the DSA drivers (in drivers/net/dsa)
select it rather than depending on it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
