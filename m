From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] macvtap: do not assume 802.1Q when send vlan
 packets
Date: Tue, 16 Jul 2013 13:03:36 -0700 (PDT)
Message-ID: <20130716.130336.215798833817030683.davem@davemloft.net>
References: <1373952994-7252-1-git-send-email-jasowang@redhat.com>
	<1373952994-7252-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, basil.gor@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373952994-7252-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 16 Jul 2013 13:36:34 +0800

> The hard-coded 8021.q proto will break 802.1ad traffic. So switch to use
> vlan->proto.
> 
> Cc: Basil Gor <basil.gor@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
