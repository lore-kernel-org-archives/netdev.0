From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 7/8] net: hns3: add vlan filter config of Ports
Date: Thu, 31 Aug 2017 14:38:27 -0700 (PDT)
Message-ID: <20170831.143827.1561921608795766649.davem@davemloft.net>
References: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
        <1504186749-8926-8-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com
To: lipeng321@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504186749-8926-8-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lipeng <lipeng321@huawei.com>
Date: Thu, 31 Aug 2017 21:39:08 +0800

> Config the self_define vlan_type as TPID(0x8100) for vlan identification.
> When normal port initialize vlan configure, set default vlan id as 0.
> 
> Signed-off-by: Mingguang Qu <qumingguang@huawei.com>
> Signed-off-by: Lipeng <lipeng321@huawei.com>

No, that's not what this patch is doing.

> @@ -3308,6 +3308,7 @@ static int hclge_add_mac_vlan_tbl(struct hclge_vport *vport,
>  		mc_desc[1].flag |= cpu_to_le16(HCLGE_CMD_FLAG_NEXT);
>  		hclge_cmd_reuse_desc(&mc_desc[2], false);
>  		mc_desc[2].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_NEXT);
> +
>  		memcpy(mc_desc[0].data, req,
>  		       sizeof(struct hclge_mac_vlan_tbl_entry));
>  		ret = hclge_cmd_send(&hdev->hw, mc_desc, 3);

All it does is add an empty line.
