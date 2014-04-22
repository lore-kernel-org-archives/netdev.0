From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] netprio_cgroup: use accessor to get id from css
Date: Tue, 22 Apr 2014 16:33:48 -0400
Message-ID: <20140422203348.GE2314@mtj.dyndns.org>
References: <cover.1398147734.git.nasa4836@gmail.com>
 <0b10af801af45fdbf4835e8da54273e9752b239f.1398147734.git.nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, lizefan@huawei.com, nhorman@tuxdriver.com,
	daniel.wagner@bmw-carit.de, jiri@resnulli.us,
	gaofeng@cn.fujitsu.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jianyu Zhan <nasa4836@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0b10af801af45fdbf4835e8da54273e9752b239f.1398147734.git.nasa4836@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 22, 2014 at 02:31:01PM +0800, Jianyu Zhan wrote:
> This is a prepared patch for converting from per-cgroup id to
> per-subsystem id.
> 
> We should not access per-cgroup id directly, since this is
> implemetation detail.
> 
> Use the accessor css_from_id() instead.
> 
> This patch has no functional change.

netprio_cgroup is a cgroup identifying controller.  We *do* want to
use per-cgroup IDs for it.

Thanks.

-- 
tejun
