From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2] vxlan: fix a potential issue when create a new vxlan
 fdb entry.
Date: Tue, 29 Nov 2016 09:20:41 +0100
Message-ID: <20161129092041.238279f5@griffin>
References: <1480384776-8252-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480384776-8252-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Nov 2016 09:59:36 +0800, Haishuang Yan wrote:
> vxlan_fdb_append may return error, so add the proper check,
> otherwise it will cause memory leak.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> Changes in v2:
>   - Unnecessary to initialize rc to zero.

Acked-by: Jiri Benc <jbenc@redhat.com>
