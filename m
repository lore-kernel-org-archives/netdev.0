From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: fix wrong usage of VXLAN_VID_MASK
Date: Fri, 13 Mar 2015 13:08:30 -0400 (EDT)
Message-ID: <20150313.130830.1630289698034246511.davem@davemloft.net>
References: <1426263233-27443-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vasily.isaenko@oracle.com
To: alexey.kodanev@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426263233-27443-1-git-send-email-alexey.kodanev@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Fri, 13 Mar 2015 19:13:53 +0300

> commit dfd8645ea1bd9127 wrongly assumes that VXLAN_VDI_MASK includes
> eight lower order reserved bits of VNI field that are using for remote
> checksum offload.
> 
> Right now, when VNI number greater then 0xffff, vxlan_udp_encap_recv()
> will always return with 'bad_flag' error, reducing the usable vni range
> from 0..16777215 to 0..65535. Also, it doesn't really check whether RCO
> bits processed or not.
> 
> Fix it by adding new VNI mask which has all 32 bits of VNI field:
> 24 bits for id and 8 bits for other usage.
> 
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Looks good, applied, thanks!
