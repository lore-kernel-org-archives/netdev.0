From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 3/9] kbuild: document RPS/XPS network
 Kconfig options
Date: Wed, 16 Nov 2011 21:58:08 -0500 (EST)
Message-ID: <20111116.215808.299077226767455988.davem@davemloft.net>
References: <cover.1321496595.git.david.decotigny@google.com>
	<e0bb736123d687a921f15e4bb0254eeeabe22dcb.1321496595.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ian.campbell@citrix.com, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com,
	jpirko@redhat.com, joe@perches.com, szymon@janc.net.pl,
	rick.jones2@hp.com, AAbdulla@nvidia.com
To: david.decotigny@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e0bb736123d687a921f15e4bb0254eeeabe22dcb.1321496595.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <david.decotigny@google.com>
Date: Wed, 16 Nov 2011 18:39:05 -0800

> This adds a description of RPS/XPS options and allow them to be
> changed at make menuconfig time.

These aren't meant to be selectable.

They are expressing internal dependencies so we don't have to crap
up the code with the complicated dependency conditional test.

They are meant to be turned on, unconditionally, when the dependencies
are met.  They are not meant to be controllable by the user.
