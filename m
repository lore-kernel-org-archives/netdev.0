From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: Re: [PATCH] of/mdio: Staticise !CONFIG_OF stubs
Date: Wed, 10 Oct 2012 10:56:40 +0100
Message-ID: <50754658.2020903@st.com>
References: <1349843618-11209-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Reply-To: srinivas.kandagatla@st.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:54717 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752716Ab2JJJ65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 05:58:57 -0400
In-Reply-To: <1349843618-11209-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/12 05:33, Mark Brown wrote:
> The !CONFIG_OF stubs aren't static so if multiple files include the
> header with this configuration then the linker will see multiple
> definitions of the stubs.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
> ---
>  include/linux/of_mdio.h |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
Acked-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
