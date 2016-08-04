From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 0/2] Add ability to configure ethernet h/w shaper
Date: Fri, 5 Aug 2016 00:17:19 +0300
Message-ID: <7bfc435d-c7d5-60a9-d6e2-ada9effcf190@linaro.org>
References: <1470345113-804-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470345113-804-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please, ignore it
It was sent by mistake

On 05.08.16 00:11, Ivan Khoronzhuk wrote:
> These two patches can be used to set per queue bandwidth with ethtool.
> I've create them as logical continuation of patchset from intel,
> that have introduced per-queue setting command month ago for ethtool
> interface
> (http://kernel.opensuse.org/cgit/kernel-source/commit/?h=rpm-4.4.9-36&
> id=feaab26abfffe381fb4c8c10d2762a753d481c6c). Actually I've not tested this
> interface and planning to send it in parallel with
> "net: ethernet: ti: cpsw: add multi-queue support"
> (https://lkml.org/lkml/2016/6/30/603), as it contains only changes to
> ethtool interface.
>
> First patch can be used to set per-channel bandwidth, second to tune
> number of per-channel descriptors. It can solve issues described by
> Schuyler. In case if per-channel bandwidth is equal to maximum
> for every channel, the driver could be switched to priority mode.
>
> Ivan Khoronzhuk (2):
>   net: core: ethtool: add per queue bandwidth command
>   net: core: ethtool: add ringparam perqueue command
>
>  include/linux/ethtool.h      |   8 ++
>  include/uapi/linux/ethtool.h |   2 +
>  net/core/ethtool.c           | 206 +++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 216 insertions(+)
>

-- 
Regards,
Ivan Khoronzhuk
