From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] of/mdio: Staticise !CONFIG_OF stubs
Date: Wed, 10 Oct 2012 10:02:23 +0200
Message-ID: <20121010100223.6b6beb7e@skate>
References: <1349843618-11209-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:48711 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab2JJICh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 04:02:37 -0400
In-Reply-To: <1349843618-11209-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 10 Oct 2012 13:33:38 +0900, Mark Brown wrote:
> The !CONFIG_OF stubs aren't static so if multiple files include the
> header with this configuration then the linker will see multiple
> definitions of the stubs.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
