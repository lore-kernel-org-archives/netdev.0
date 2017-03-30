From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2] openvswitch: Fix ovs_flow_key_update()
Date: Thu, 30 Mar 2017 22:06:14 +0200
Message-ID: <20170330220614.7079d316@griffin>
References: <1490902563-19288-1-git-send-email-yihung.wei@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: joe@ovn.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yi-Hung Wei <yihung.wei@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490902563-19288-1-git-send-email-yihung.wei@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Mar 2017 12:36:03 -0700, Yi-Hung Wei wrote:
> ovs_flow_key_update() is called when the flow key is invalid, and it is
> used to update and revalidate the flow key. Commit 329f45bc4f19
> ("openvswitch: add mac_proto field to the flow key") introduces mac_proto
> field to flow key and use it to determine whether the flow key is valid.
> However, the commit does not update the code path in ovs_flow_key_update()
> to revalidate the flow key which may cause BUG_ON() on execute_recirc().
> This patch addresses the aforementioned issue.
> 
> Fixes: 329f45bc4f19 ("openvswitch: add mac_proto field to the flow key")
> Signed-off-by: Yi-Hung Wei <yihung.wei@gmail.com>

Acked-by: Jiri Benc <jbenc@redhat.com>

Thanks!

 Jiri
