From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Wed, 11 Jan 2017 13:14:32 -0800
Message-ID: <5b5a3231-eed4-ef29-b32a-a19077681dad@gmail.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: lars.persson@axis.com, niklass@axis.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35925 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760451AbdAKVOk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:14:40 -0500
Received: by mail-pf0-f194.google.com with SMTP id b22so22526pfd.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 13:14:40 -0800 (PST)
In-Reply-To: <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2017 06:52 AM, Joao Pinto wrote:
> This patch renames stmicro/stmmac to synopsys/ since it is a standard
> ethernet software package regarding synopsys ethernet controllers, supporting
> the majority of Synopsys Ethernet IPs. The config IDs remain the same, for
> retro-compatibility, only the description was changed.

Do re really have to do this? ST Micro were the first to upstream
support for a Synopsys IP, and it was later on identified as being
"stmicro" instead of "synopsys" (during the big driver move under
drivers/net/ethernet) whichever came first in the driver essentially "wins".

As mentioned before, although git is able to track renames, git log does
not automatically have --follow, so it can be hard for people to track
down the (new) history of the driver.

Personally, I don't see much value in doing this rename, especially when
all the driver internal structures are still going to be named with
stmmac (and please don't even think about doing a s/stmmac/snps/ inside
the driver ;)).

My 2 cents.
-- 
Florian
