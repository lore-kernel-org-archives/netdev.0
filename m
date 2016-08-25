From: David Miller <davem@redhat.com>
Subject: Re: [PATCH -next] ibmvnic: fix error return code in ibmvnic_probe()
Date: Thu, 25 Aug 2016 16:41:23 -0700 (PDT)
Message-ID: <20160825.164123.36841950077292550.davem@redhat.com>
References: <1472046478-1427-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
 netdev@vger.kernel.org, weiyongjun1@huawei.com, paulus@samba.org,
 linuxppc-dev@lists.ozlabs.org
To: weiyj.lk@gmail.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1472046478-1427-1-git-send-email-weiyj.lk@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 24 Aug 2016 13:47:58 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return error code -ENOMEM from the dma_map_single error
> handling case instead of 0, as done elsewhere in this function.
> 
> Fixes: 032c5e82847a ("Driver for IBM System i/p VNIC protocol")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
